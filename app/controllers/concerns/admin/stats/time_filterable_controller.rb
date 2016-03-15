module Admin
  module Stats
    module TimeFilterableController
      extend ActiveSupport::Concern

      included do
        before_action :set_year, only: %i(year month)
        before_action :set_month, only: :month
      end

      private

      def set_year
        @year = params[:year].to_i
      end

      def set_month
        @month = params[:month].to_i
      end

      def filter_by_time(relation)
        default_args = [1, 0, 0, 0, DateTime.now.offset]
        if @month
          begins_at = DateTime.new(@year, @month, *default_args)
          ends_at = begins_at.end_of_month
        elsif @year
          begins_at = DateTime.new(@year, 1, *default_args)
          ends_at = begins_at.end_of_year
        end
        return relation if begins_at.nil? || ends_at.nil?
        relation.where(created_at: begins_at..ends_at)
      end
    end
  end
end
