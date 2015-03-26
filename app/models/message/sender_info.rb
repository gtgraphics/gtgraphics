# == Schema Information
#
# Table name: message_sender_infos
#
#  id         :integer          not null, primary key
#  ip         :string(255)
#  created_at :datetime
#

class Message::SenderInfo < ActiveRecord::Base
  validates :ip, presence: true, strict: true

  THRESHOLD = 1.day

  def self.recent?(ip)
    return false if ip.blank?
    sweep
    where('created_at > ?', THRESHOLD.ago).exists?(ip: ip)
  end

  def self.sweep
    where('created_at <= ?', THRESHOLD.ago).delete_all
  end
end
