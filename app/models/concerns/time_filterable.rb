module TimeFilterable
  extend ActiveSupport::Concern

  module ClassMethods
    def by_year(year)
      begins_at = Time.new(year).in_time_zone
      ends_at = begins_at.end_of_year
      where(created_at: begins_at..ends_at)
    end

    def by_month(year, month)
      begins_at = Time.new(year, month).in_time_zone
      ends_at = begins_at.end_of_month
      where(created_at: begins_at..ends_at)
    end

    def by_day(date)
      begins_at = date.in_time_zone
      ends_at = date.end_of_day
      where(created_at: begins_at..ends_at)
    end
  end
end
