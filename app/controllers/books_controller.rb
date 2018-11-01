class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy, :vote, :unvote]

  # GET /books
  # GET /books.json
  def index
    @books = Book.all
    # session[:current_voter_name] = vote_params[:voter_name] if vote_params[:voter_name]
    SessionService.set_voter_name(vote_params)
    # session_service = SessionService.new
    # session_service.set_voter_name(vote_params)
  end

  # GET /books/1
  # GET /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books
  # POST /books.json
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        format.html { redirect_to books_path, notice: 'Book was successfully created.' } # in redirects, @book goes to the url for the book itself; books_path goes to the index page
        #format.html sends html back to browser
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to books_path, notice: 'Book successfully updated.' }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    # TODO: figure out how errors work and make this use a real error / real validations?
    # TODO: ?? have it only validate if done via html?
    if @book.votes.any?
      @notice = 'Cannot delete a book that has been voted for!'
    else
      @book.destroy
      @notice = 'Book successfully deleted.'
    end
    respond_to do |format|
      format.html { redirect_to books_url, notice: @notice }
      format.json { head :no_content }
    end
  end

  def vote
    @book.votes.create(vote_params)
    respond_to do |format|
      format.html { redirect_to books_url, notice: @notice }
      format.json { head :no_content }
    end
  end

  def unvote
    voters_vote = @book.votes.find_by(:voter_name => session[:current_voter_name])
    if voters_vote
      voters_vote.destroy
    else
      @notice = 'You have not voted for this book!'
    end
    respond_to do |format|
      format.html { redirect_to books_url, notice: @notice }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_book
    @book = Book.find(params[:id]) || Book.find(params[:book_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def book_params
    params.require(:book).permit(:title, :author, :genre, :description)
  end

  def vote_params
    params.permit(:voter_name)
  end

end
