class ProjectsController < ApplicationController

  respond_to :html, :json, :yaml, :xml

  def index
    respond_with(@projects = Project.all)
  end

  def show
    respond_with(@project = Project.get(params[:id]))
  end

  def new
  end

  def create
    respond_with(@project = Project.create(params[:Project]))
  end

end
