module Admin
  module Stats
    class VisitsController < Admin::Stats::ApplicationController
      include Admin::Stats::TimeFilterableController

      def index
        partition = 'OVER (PARTITION BY hittable_type, hittable_id)'
        @visits = filter_by_time(
          Visit.uniq.select(:hittable_id, :hittable_type)
          .select("COUNT(id) #{partition} AS count")
          .select("MAX(created_at) #{partition} AS last_visited_at")
          .order('count DESC').preload(page: :translations)
        )

        respond_to :html
      end

      def year
        respond_to do |format|
          format.html
        end
      end

      def month
        respond_to do |format|
          format.html
        end
      end
    end
  end
end
