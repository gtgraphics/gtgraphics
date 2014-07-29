class Page::PermalinksController < ApplicationController
  def show
    @page = Page.find_by!(permalink: params[:id])
    redirect_to @page
  end
end