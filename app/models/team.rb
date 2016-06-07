class Team < ActiveRecord::Base
  has_many :registrations, as: :registerable
  has_many :seasons, through: :registrations

  belongs_to :division
  belongs_to :region
end
