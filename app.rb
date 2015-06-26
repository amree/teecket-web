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
    if @params.size > 0
      validate(@params[:from], @params[:to], @params[:date])
    end

    if @errors.empty?
      search(@params[:from], @params[:to], @params[:date])
    end

    erb :index
  end

  def validate(from, to, date)
    if from.nil? || to.nil? || date.nil?
      @errors << "Make sure you've entered all the inputs"
    elsif from.empty? || to.empty? || date.empty?
      @errors << "Make sure you've entered all the inputs"
    end
  end

  def search(from, to, date)
    @flights = Teecket.search(from: from, to: to, date: date)
  end

  run! if app_file == $0
end
