class PostsController < ApplicationController

  respond_to :html, :json, :yaml, :xml

  def index
    respond_with(@posts = Post.all)
  end

  def show
    respond_with(@post = Post.get(params[:id]))
  end

  def create
    respond_with(@post = Post.create(params[:post]))
  end

  def update
    @post.update(params[:post])
    respond_with(@post)
  end

end
