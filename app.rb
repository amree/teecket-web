require "sinatra/base"
require "tilt/erubis"
require "teecket"

class App < Sinatra::Base
  enable :logging

  before do
    @params = params

    @flights = []
    @errors = []

    @airports = [
      ['Alor Setar', 'AOR'],
      ['Bintulu', 'BTU'],
      ['Johor Bahru', 'JHB'],
      ['Kota Bharu', 'KBR'],
      ['Kota Kinabalu', 'BKI'],
      ['Kuala Lumpur', 'KUL'],
      ['Kuala Terengganu', 'TGG'],
      ['Kuching', 'KCH'],
      ['Labuan', 'LBU'],
      ['Langkawi', 'LGK'],
      ['Miri', 'MYY'],
      ['Penang', 'PEN'],
      ['Sandakan', 'SDK'],
      ['Sibu', 'SBW'],
      ['Subang', 'SZB'],
      ['Tawau', 'TWU'],
    ]
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
