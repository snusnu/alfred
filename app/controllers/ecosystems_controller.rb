class EcosystemsController < ApplicationController

  respond_to :html

  def show
    respond_with(@ecosystem = Ecosystem.get(params[:id]))
  end

  def stats
  end

end
