class AddEventRefToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :event, index: true
  end
end
