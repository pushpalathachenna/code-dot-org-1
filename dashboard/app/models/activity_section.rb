# == Schema Information
#
# Table name: activity_sections
#
#  id                 :integer          not null, primary key
#  lesson_activity_id :integer          not null
#  seeding_key        :string(255)      not null
#  position           :integer          not null
#  properties         :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_activity_sections_on_lesson_activity_id  (lesson_activity_id)
#  index_activity_sections_on_seeding_key         (seeding_key) UNIQUE
#

# An ActivitySection represents a part of an activity in a lesson plan.
# An ActivitySection may contain a progression of script levels, or
# may simply contain formatted text and other visual information.
#
# @attr [String] title - The user-visible heading of this section of the activity
# @attr [boolean] remarks - Whether to show the remarks icon
# @attr [boolean] slide - Whether to show the slides icon
# @attr [String] description - Text describing the activity
# @attr [Array<Hash>] tips - An array of instructional tips to display
class ActivitySection < ApplicationRecord
  include SerializedProperties

  belongs_to :lesson_activity
  has_one :lesson, through: :lesson_activity

  has_many :script_levels

  serialized_attrs %w(
    title
    remarks
    slide
    description
    tips
  )
end
