module HitCountable
  extend ActiveSupport::Concern

  def increment_hits!
    update_column :hits_count, hits_count.next if persisted?
  end
end