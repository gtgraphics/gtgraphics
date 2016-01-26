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
    end
  end
end
