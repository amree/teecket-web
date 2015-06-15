require "sinatra/base"
require "tilt/erubis"
require "teecket"

class App < Sinatra::Base
  configure do
    enable :logging
    file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end

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
    @params[:from] = @params[:from] || ""
    @params[:to] = @params[:to] || ""
    @params[:date] = @params[:date] || ""

    if @params[:submit] && (@params[:from].empty? || @params[:to].empty? || @params[:date].empty?)
      @errors << "Make sure you've entered all the inputs"
    end
  end

  def search
    unless @params[:submit].nil?
      @flights = Teecket.search(from: @params[:from], to: @params[:to], date: @params[:date])
    end
  end

  run! if app_file == $0
end
