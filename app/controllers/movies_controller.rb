class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
    @settings = session['settings']
  end

  def index
    @all_ratings = Movie.ratings 
    @sort = params[:sort]
    @selected_ratings = params[:ratings]
    if @selected_ratings.nil?
      @selected_ratings = {}
    end

    #user either just got here or did some "non action" action
    if (@sort.nil? and @selected_ratings=={})
      @search_session = true
    end

    #user clicked to sort by field name
    if !@sort.nil? or (@search_session and !session['sorted'].nil?)
      if @sort.nil?
        @sort = session['sorted']
      else
        session['sorted']=@sort
      end

      @movies = Movie.order(@sort)

      if !session['filtered'].nil?
        @selected_ratings = session['filtered']
        @movies = @movies.select do |film|
          @selected_ratings.has_key? film.rating
        end
      end

    #user clicked to filter by rating
    elsif @selected_ratings != {} or (@search_session and !session['filtered'].nil?)
      if @selected_ratings == {}
        @selected_ratings = session['filtered']
      else
        session['filtered']=@selected_ratings
      end

      if !session['sorted'].nil?
        @sort = session['sorted']
        @movies = Movie.order(@sort)
      else
        @movies = Movie.all
      end
      @movies = @movies.select do |film|
        @selected_ratings.has_key? film.rating
      end

    else
      @movies = Movie.all
    end
    session['settings'] = {}
    if !session['sorted'].nil?
      session['settings'][:sort]=session['sorted']
    end
    if !session['filtered'].nil?
      session['settings'][:ratings]=session['filtered']
    end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path(session['settings'])
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path(session['settings'])
  end

end
