class KeywordsController < ApplicationController
  # GET /keywords/new.xml
  def new
    @keyword = Keyword.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @keyword }
    end
  end

  # POST /keywords
  # POST /keywords.xml
  def create
    @movie    = Movie.find(params[:movie_id])
    @keyword  = @movie.keywords.build(params[:keyword])

    respond_to do |format|
      if @keyword.save
        format.html { redirect_to(edit_movie_path(@movie), :notice => 'Keyword was successfully created.') }
        format.xml  { render :xml => @keyword, :status => :created, :location => @keyword }
      else
        format.html { redirect_to(@movie, :notice => 'Keyword was failed to created.') }
        format.xml  { render :xml => @keyword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /keywords/1
  # DELETE /keywords/1.xml
  def destroy
    @keyword = Keyword.find(params[:id])
    @keyword.destroy

    respond_to do |format|
      format.html { redirect_to(edit_movie_path(@keyword.movie)) }
      format.xml  { head :ok }
    end
  end
end
