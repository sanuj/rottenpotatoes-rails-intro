class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @sort_by = params[:sort_by]
    @all_ratings = Movie.get_ratings

    ratings = Hash[@all_ratings.map {|r| [r, 1]}]
    redirect = false
    redirect_params = {}

    if (params[:ratings].nil? and !session[:ratings].nil?)
      redirect = true
      redirect_params[:ratings] = session[:ratings]
    end
    if (params[:sort_by].nil? and !session[:sort_by].nil?)
      redirect = true
      redirect_params[:sort_by] = session[:sort_by]
    end
    if redirect
      redirect_params = redirect_params.merge(params)
      flash.keep
      redirect_to movies_path redirect_params
    end
    session[:sort_by] = params[:sort_by]
    session[:ratings] = params[:ratings] || ratings
    @sort_by = params[:sort_by]
    @selected_ratings = session[:ratings].keys || @all_ratings

    @movies = Movie.where(:rating => @selected_ratings)
    if params[:sort_by]
      @movies = @movies.order(@sort_by)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
