# == Schema Information
#
# Table name: clients
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  country     :string(2)
#  website_url :string(255)
#

class Client < ActiveRecord::Base
  include Searchable

  sanitizes :name, with: :squish
  sanitizes :country, with: :upcase

  acts_as_searchable_on :name

  has_many :projects, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :country, length: { is: 2 }, allow_blank: true
  validates :website_url, url: true, allow_blank: true

  def to_s
    name
  end
end
