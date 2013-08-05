# == Schema Information
#
# Table name: shouts
#
#  id         :integer          not null, primary key
#  nickname   :string(255)
#  message    :text
#  x          :integer          not null
#  y          :integer          not null
#  ip         :string(255)
#  created_at :datetime
#  updated_at :datetime
#  user_agent :string(255)
#

class Shout < ActiveRecord::Base
  COORDINATES_PADDING = 10

  validates :nickname, presence: true
  validates :message, presence: true, length: { maximum: 300 }
  validates :x, presence: true, numericality: { only_integer: true }
  validates :y, presence: true, numericality: { only_integer: true }
  validate :check_coordinates_uniqueness

  def browser
    "#{parsed_user_agent.browser} #{parsed_user_agent.version}"
  end

  def coordinates
    [x, y]
  end

  def edited?
    updated_at != created_at
  end

  def browser(locale = I18n.locale)
    "#{I18n.translate(parsed_user_agent.name, scope: :browsers)} #{parsed_user_agent.version}"
  end

  delegate :os, :mobile?, to: :parsed_user_agent

  def x_padding
    (x-COORDINATES_PADDING)..(x+COORDINATES_PADDING) if x
  end

  def y_padding
    (y-COORDINATES_PADDING)..(y+COORDINATES_PADDING) if y
  end

  def to_s
    nickname
  end

  private
  def check_coordinates_uniqueness
    errors.add(:taken) if Shout.exists?(x: x_padding, y: y_padding)
  end

  def parsed_user_agent
    @parsed_user_agent ||= UserAgent.new(user_agent)
  end
end