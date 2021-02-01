class Task < ApplicationRecord
  validates_presence_of :description

  acts_as_list
end
