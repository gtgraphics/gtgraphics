module Ajax
  class ActivityBadgesController < ApplicationController
    layout false

    def show
      @page = Page.find(params[:page_id])
      @count = rand(10)

      respond_to do |format|
        format.html
      end
    end
  end
end
