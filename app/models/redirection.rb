# == Schema Information
#
# Table name: redirections
#
#  id              :integer          not null, primary key
#  source_path     :string(255)
#  destination_url :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Redirection < ActiveRecord::Base
  validates :source_path, presence: true, uniqueness: true
  validates :destination_url, presence: true # TODO Format = Path || URL
  validate :check_path_uniqueness

  before_validation :sanitize_source_path

  private
  def check_path_uniqueness
    errors.add(:source_path, :taken) if source_path.present? and Page.exists?(path: source_path)
  end

  def sanitize_source_path
    self.source_path = source_path.strip.gsub(/\A\/+|\/+\z/, '') # strip leading and ending slashes
  end
end
