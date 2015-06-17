require "sinatra/base"
require "tilt/erubis"
require "teecket"

require_relative "helpers/data"

class App < Sinatra::Base
  enable :logging

  helpers Sinatra::Teecket::Data

  before do
    @params = params

    @flights = []
    @errors = []

    @airports = airports
  end

  get '/' do
    index
  end

  get '/:from/:to/:date' do
    index
  end

  not_found do
    status 404
    erb :oops
  end

  private

  def index
    validate

    if !@params[:to].nil? && @errors.empty?
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
