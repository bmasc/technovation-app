class Event < ActiveRecord::Base
  has_many :teams
  belongs_to :region

  scope :display_order, -> {
    order(is_virtual: :desc, name: :asc)
  }

  scope :open_for_signup, -> {
    display_order.where("extract(year from when_to_occur) = ?", Setting.year)
  }

  scope :open_for_signup_by_region, ->(region_id) {
    open_for_signup.where("(region_id = ?) OR ( is_virtual = ? AND extract(year from when_to_occur) = ?)", region_id, true, Setting.year)
  }


  scope :nonconflicting_events, ->(conflict_regions) {
    open_for_signup.where("region_id not in (?) OR region_id=-1 OR region_id IS NULL", (conflict_regions << -1))
  }

  scope :virtual, -> {
    open_for_signup.where(is_virtual: true)
  }

  def self.virtual_for_current_season
    virtual.first
  end

end
