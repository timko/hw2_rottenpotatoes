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
    if @sort.nil? and @selected_ratings == {} and !(session['sorted'].nil? and session['filtered'].nil?)
      flash.keep
      redirect_to movies_path(:ratings => session['filtered'], :sort => session['sorted'])
    end
    
    #this will only occur from a redirect 
    if !@sort.nil? and @selected_ratings != {}
      session['sorted']=@sort
      session['filtered']=@selected_ratings
      @sort_by_t = @sort == 'title' ? 'hilite' : ''
      @sort_by_d = @sort == 'release_date' ? 'hilite' : ''
      @checked = {}
      @all_ratings.each_key do |rate|
            @checked[rate] = @selected_ratings.has_key? rate
      end
      @movies = Movie.where(:rating => @selected_ratings.keys).order(@sort)
      return
    end

    #user clicked to sort by field name
    if !@sort.nil? #or (@search_session and !session['sorted'].nil?)
      session['sorted']=@sort

      if !session['filtered'].nil?
        flash.keep
        redirect_to movies_path(:sort => @sort, :ratings => session['filtered'])
      end
      @sort_by_t = @sort == 'title' ? 'hilite' : ''
      @sort_by_d = @sort == 'release_date' ? 'hilite' : ''
      @movies = Movie.order(@sort)

    #user clicked to filter by rating
    elsif @selected_ratings != {}
      session['filtered']=@selected_ratings

      if !session['sorted'].nil?
        flash.keep
        redirect_to movies_path(:sort => session['sorted'], :ratings => @selected_ratings)
      else
      	@checked = {}
      	@all_ratings.each_key do |rate|
            @checked[rate] = @selected_ratings.has_key?(rate)
      	end
        @movies = Movie.where(:rating => @selected_ratings.keys)
      end

    else
      @checked = {}
      @all_ratings.each_key do |rate|
          @checked[rate] = true
      @movies = Movie.all
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
