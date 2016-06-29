class Account < ActiveRecord::Base
  PROFILE_TYPES = {
    student: 0,
    judge: 1,
    admin: 2,
    mentor: 4,
    coach: 5,
  }

  attr_accessor :existing_password

  has_secure_password

  has_one :admin_profile
  has_one :coach_profile
  has_one :judge_profile
  has_one :mentor_profile
  has_one :student_profile

  accepts_nested_attributes_for :coach_profile, reject_if: :all_blank
  accepts_nested_attributes_for :judge_profile, reject_if: :all_blank
  accepts_nested_attributes_for :mentor_profile, reject_if: :all_blank
  accepts_nested_attributes_for :student_profile, reject_if: :all_blank

  validates :email, presence: true, uniqueness: true
  validates :password, :password_confirmation, presence: { on: :create }
  validates :existing_password, valid_password: true,
    if: :changes_require_password?

  validates :date_of_birth, :first_name, :last_name, :city, :region, :country,
    presence: true

  validates_associated :coach_profile, unless: :coach_profile_blank?
  validates_associated :judge_profile, unless: :judge_profile_blank?
  validates_associated :mentor_profile, unless: :mentor_profile_blank?
  validates_associated :student_profile, unless: :student_profile_blank?

  def self.has_token?(token)
    exists?(auth_token: token)
  end

  def self.find_with_token(token)
    find_by(auth_token: token) || NoAuthFound.new
  end

  def self.find_profile_with_token(token, profile)
    auth = find_with_token(token)

    auth.send("#{profile}_profile") or
      auth.admin_profile or
        NoProfileFound.new(profile)
  end

  def self.registerable_profile(value)
    registerable_profiles.select { |_, v| v == Integer(value) }.keys.first
  end

  def self.registerable_profiles
    PROFILE_TYPES.reject { |k, _| k == :admin }
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def address_details
    [city, region, country].join(', ')
  end

  def sign_consent_form!
    update_attributes(consent_signed_at: Time.current)
  end

  def build_profiles
    self.class.registerable_profiles.keys.each do |name|
      send("build_#{name}_profile") if send("#{name}_profile").nil?
    end
  end

  def method_missing(method_name, *args, &block)
    name = method_name.to_s.sub('profile_', '')
    if !!(profile = profiles.select { |prof| prof.respond_to?(name) }.first)
      profile.public_send(name, *args, &block)
    else
      super
    end
  end

  private
  def profiles
    PROFILE_TYPES.keys.map { |name| send("#{name}_profile") }
  end

  def changes_require_password?
    persisted? && (email_changed? || password_digest_changed?)
  end

  def coach_profile_blank?
    all_attributes_blank?(coach_profile)
  end

  def judge_profile_blank?
    all_attributes_blank?(judge_profile)
  end

  def mentor_profile_blank?
    all_attributes_blank?(mentor_profile)
  end

  def student_profile_blank?
    all_attributes_blank?(student_profile)
  end

  def all_attributes_blank?(profile)
    !!profile and
      profile.attributes.select { |k, _| k != 'type' }.values.all?(&:blank?)
  end

  class NoAuthFound
    PROFILE_TYPES.keys.each do |name|
      define_method "#{name}_profile" do
        NoProfileFound.new(name)
      end
    end
  end

  class NoProfileFound
    def initialize(*attempted_profile)
      @attempted_profile = attempted_profile
    end

    def authenticated?
      false
    end
  end
end
