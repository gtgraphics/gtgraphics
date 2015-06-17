module Router
  module Legacy
    class BaseConstraint
      protected

      def path_matcher(request)
        /\/#{Regexp.escape(request.params[:slug])}\z/
      end
    end
  end
end
