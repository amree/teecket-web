require "sinatra/base"
require "tilt/erubis"
require "teecket"

class App < Sinatra::Base
  before do
    @params = params

    @flights = []
    @errors = []
  end

  get '/' do
    index
  end

  get '/:from/:to/:date' do
    index
  end

  private

  def index
    validate

    if @errors.empty?
      search
    end

    erb :index
  end

  def validate
    unless @params[:from].nil?
      if @params[:from].empty? || @params[:to].empty? || @params[:date].empty?
        @errors << "Make sure you've entered all the inputs"
      end
    end
  end

  def search
    @flights = Teecket.search(from: @params[:from], to: @params[:to], date: @params[:date])
  end

  run! if app_file == $0
end
