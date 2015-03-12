class Team < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name_and_year, use: :slugged

  validates :name, presence: true, uniqueness: {
    scope: :year,
    case_sensitive: false,
  }
  validates_presence_of :region, :year

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "64x64>" }, :default_url => "/images/:style/missing.png"
  has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "64x64>" }, :default_url => "/images/:style/missing.png"
  has_attached_file :plan 

  has_attached_file :screenshot1, :styles => { :medium => "300x300>", :thumb => "64x64>" }, :default_url => "/images/:style/missing.png"
  has_attached_file :screenshot2, :styles => { :medium => "300x300>", :thumb => "64x64>" }, :default_url => "/images/:style/missing.png"
  has_attached_file :screenshot3, :styles => { :medium => "300x300>", :thumb => "64x64>" }, :default_url => "/images/:style/missing.png"
  has_attached_file :screenshot4, :styles => { :medium => "300x300>", :thumb => "64x64>" }, :default_url => "/images/:style/missing.png"
  has_attached_file :screenshot5, :styles => { :medium => "300x300>", :thumb => "64x64>" }, :default_url => "/images/:style/missing.png"

  # has_attached_file :submission_attachments

  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/

  validates_attachment_content_type :screenshot1, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :screenshot2, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :screenshot3, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :screenshot4, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :screenshot5, :content_type => /\Aimage\/.*\Z/

  validates_attachment :plan, content_type: { content_type: "application/pdf" }
  
  enum division: {
    ms: 0,
    hs: 1,
    x: 2,
  }
  enum region: [
    :ushs, # High School - US/Canada
    :mexicohs, # High School - Mexico/Central America/South America
    :europehs, #High School - Europe/Australia/New Zealand/Asia
    :africahs, #High School - Africa
    :usms, #Middle School - US/Canada
    :mexicoms, #Middle School - Mexico/Central America/South America/Africa
    :europems, #Middle School - Europe/Australia/New Zealand/Asia
  ]

  has_many :team_requests
  has_many :categories

  has_many :members, -> {where 'team_requests.approved = ?', true}, {through: :team_requests, source: :user}
  has_many :pending, -> {where 'team_requests.approved != ?', true}, {through: :team_requests, source: :user}

  has_many :rubrics
  has_many :judges, through: :rubrics, source: :user

  has_one :event

  scope :old, -> {where 'year < ?', Setting.year}
  scope :current, -> {where year: Setting.year}
  scope :has_category, -> (cat) {where('category_id = ?', cat)}
  scope :has_division, -> (div) {where('division = ?', div)}
  scope :has_region, -> (reg) {where('region = ?', reg)}
  scope :has_event, -> (ev) {where('event_id = ?', ev.id)}

  #http://stackoverflow.com/questions/14762714/how-to-list-top-10-school-with-active-record-rails
  #http://stackoverflow.com/questions/8696005/rails-3-activerecord-order-by-count-on-association
  #scope :by_score, joins: :rubrics, group: "teams.id", order: "AVG(rubrics.score) DESC"
#  scope :by_num_rubrics, :joins => :rubrics, :group => 'teams.id', :order => 'COUNT(rubrics) ASC'

  # def self.by_scores
  #   select('teams.id, AVG(rubrics.score) AS avg_score').
  #   joins(:rubrics).
  #   group('teams.id').
  #   order('avg_score DESC')
  # end

  def avg_score
    rubrics.average(:score)
  end

  def num_rubrics
    rubrics.length
  end

  # def self.by_num_rubrics
  #   select('teams.id, COUNT(rubrics.id) AS num_rubrics').
  #   joins(:rubrics).
  #   group('teams.id').
  #   order('num_rubrics ASC')
  # end

  def name_and_year
    "#{name}-#{year}"
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  # division update logic
  def update_division!
    div = :x

    # team division is the age of the oldest student
    div = members.student
      .map(&:division)
      .max_by {|d| Team.divisions[d]}

    # or if there are too many / not-enough students
    student_count = members.student.count
    if student_count < 1 or student_count > 5
      div = :x
    end

    self.division = div
    self.save!
  end

  def ineligible?
    division.to_sym == :x
  end

  def check_empty!
    if members.count == 0
      team_requests.delete_all
      self.destroy
    end
  end

  def missing_field?(a)
     evaled = eval(a)
     (evaled.nil? or (evaled.class.name == 'String' and evaled.length == 0)) or (evaled.class.name == 'Paperclip::Attachment' and eval(a+'_file_name').nil?)
  end

  def check_completeness
    required = ['category_id', 'name', 'about', 'region', 'code', 'pitch', 'demo', 'description', 'avatar', 'logo',  'plan', 'screenshot1', 'screenshot2', 'screenshot3']
    missing = required.select {|a| 
      if (missing_field?(a))
        a
      end
     }
    missing.join(', ')
  end

end
