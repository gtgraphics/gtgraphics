class PortfoliosController < ApplicationController
  respond_to :html

  before_action :set_portfolio, only: [:show, :edit, :update, :destroy]

  def index
    @portfolios = Portfolio.all
    respond_with @portfolios
  end

  def show
    respond_with @portfolio
  end

  def new
    @portfolio = Portfolio.new
    respond_with @portfolio
  end

  def create
    @portfolio = Portfolio.create(portfolio_params)
    respond_with @portfolio
  end

  def edit
    respond_with @portfolio
  end

  def update
    @portfolio.update(portfolio_params)
    respond_with @portfolio
  end

  def destroy
    @portfolio.destroy
    respond_with @portfolio
  end

  private
  def portfolio_params
    params.require(:portfolio).permit(:owner_id, :slug, :description)
  end

  def set_portfolio
    @portfolio = Portfolio.find_by_slug!(params[:id])
  end
end
