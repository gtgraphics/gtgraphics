module PeriodFilterable
  extend ActiveSupport::Concern

  module ClassMethods
    def created(date)
      if date.present?
        where(created_at: _parse_period(date))
      else
        all
      end
    end

    def updated(date)
      if date.present?
        where(updated_at: _parse_period(date))
      else
        all
      end
    end

    private
    def _parse_period(date)
      case date.to_s.downcase
      when 'today'
        Date.today.beginning_of_day..Date.today.end_of_day
      when 'yesterday'
        Date.yesterday.beginning_of_day..Date.yesterday.end_of_day
      when 'week'
        7.days.ago.beginning_of_day..Date.today.end_of_day
      when 'month'
        1.month.ago.beginning_of_day..Date.today.end_of_day
      else
        date.beginning_of_day..date.end_of_day
      end
    end
  end
end