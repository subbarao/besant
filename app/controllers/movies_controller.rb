class MoviesController < ApplicationController

  before_filter :authenticate, :except => [:autocomplete, :index, :show, :positive, :negative, :mixed]

  #caches_page   :index, :show
  #cache_sweeper :movie_sweeper, :only => [:update, :create]
  #caches_action :show, :if => proc { params[:page].blank? }


  def autocomplete
    movies = Movie.where(["movies.name like ?","%#{params[:term]}%"]).to_ary
    render :json => movies.inject([]) { |a,m| a << { :label => m.name, :url => movie_path(m) } }
  end

  # GET /movies
  # GET /movies.xml
  def index
    @movies = Movie.active

    respond_to do |format|
      format.mobile  
      format.html # index.html.erb
      format.xml  { render :xml => @movies }
    end
  end

  # GET /movies/1
  # GET /movies/1.xml
  def show
    @movie = Movie.find(params[:id].to_i)
    @tweets = @movie.tweets.assesed.paginate(:page => params[:page], :per_page => 21)
    render :action => :show
  end

  # GET /movies/new
  # GET /movies/new.xml
  def new
    @movie = Movie.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @movie }
    end
  end

  # GET /movies/1/edit
  def edit
    @movie = Movie.find(params[:id].to_i)
    @tweets = @movie.tweets.fresh.paginate(:page => params[:page])
  end

  # GET /movies/1/edit
  def sync
    @movie = Movie.find(params[:id].to_i).tap {|t| t.keywords.query_twitter }
    @tweets = @movie.tweets.paginate(:page => params[:page])
    render :action => 'edit'
  end

  %w(positive negative mixed spotlight fresh terminate external).each do |method|
    define_method(method) do
      @movie = Movie.find(params[:id].to_i)
      @tweets = @movie.tweets.send(method).paginate(:page => params[:page], :per_page => 21)
      render :action => :show
    end

    define_method("edit_#{method}") do
      @movie  = Movie.find(params[:id].to_i)
      @search = @movie.tweets.send(method).search(params[:search])
      @tweets = @search.paginate(:page => params[:page])
      render :action => :admin
    end
  end


  # POST /movies
  # POST /movies.xml
  def create
    @movie = Movie.new(params[:movie])

    respond_to do |format|
      if @movie.save
        expire_page :action => :index
        format.html { redirect_to(@movie, :notice => 'Movie was successfully created.') }
        format.xml  { render :xml => @movie, :status => :created, :location => @movie }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @movie.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /movies/1
  # PUT /movies/1.xml
  def update
    @movie = Movie.find(params[:id].to_i)
    respond_to do |format|
      if @movie.update_attributes(params[:movie])
        expire_page :action => :index
        format.html { redirect_to(@movie, :notice => 'Movie was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @movie.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.xml
  def destroy
    @movie = Movie.find(params[:id].to_i)
    @movie.destroy
    expire_page :action => :index

    respond_to do |format|
      format.html { redirect_to(movies_url) }
      format.xml  { head :ok }
    end
  end
end
