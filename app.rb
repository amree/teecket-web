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
      ['Autralia', 'Darwin', 'DRW'],
      ['Autralia', 'Gold Coast', 'OOL'],
      ['Autralia', 'Melbourne', 'MEL'],
      ['Autralia', 'Perth', 'PER'],
      ['Autralia', 'Sydney', 'SYD'],
      ['Bangladesh', 'Dhaka', 'DAC'],
      ['Brunei Darussalam', 'Brunei', 'BWN'],
      ['Malaysia', 'Alor Setar', 'AOR'],
      ['Malaysia', 'Bintulu', 'BTU'],
      ['Malaysia', 'Ipoh', 'IPH'],
      ['Malaysia', 'Johor Bahru', 'JHB'],
      ['Malaysia', 'Kerteh', 'KTE'],
      ['Malaysia', 'Kota Bharu', 'KBR'],
      ['Malaysia', 'Kota Kinabalu', 'BKI'],
      ['Malaysia', 'Kuala Lumpur', 'KUL'],
      ['Malaysia', 'Kuala Terengganu', 'TGG'],
      ['Malaysia', 'Kuantan', 'KUA'],
      ['Malaysia', 'Kuching', 'KCH'],
      ['Malaysia', 'Labuan', 'LBU'],
      ['Malaysia', 'Langkawi', 'LGK'],
      ['Malaysia', 'Miri', 'MYY'],
      ['Malaysia', 'Penang', 'PEN'],
      ['Malaysia', 'Sandakan', 'SDK'],
      ['Malaysia', 'Sibu', 'SBW'],
      ['Malaysia', 'Subang', 'SZB'],
      ['Malaysia', 'Tawau', 'TWU'],
      ['Indonesia', 'Bali', 'DPS'],
      ['Indonesia', 'Balikpapan', 'BPN'],
      ['Indonesia', 'Banda Aceh', 'BTJ'],
      ['Indonesia', 'Bandung', 'BDO'],
      ['Indonesia', 'Jakarta', 'CGK'],
      ['Indonesia', 'Lombok', 'LOP'],
      ['Indonesia', 'Makassar', 'UPG'],
      ['Indonesia', 'Medan - Kualanamu', 'KNO'],
      ['Indonesia', 'Padang', 'PDG'],
      ['Indonesia', 'Palembang', 'PLM'],
      ['Indonesia', 'Pekanbaru', 'PKU'],
      ['Indonesia', 'Semarang', 'SRG'],
      ['Indonesia', 'Solo', 'SOC'],
      ['Indonesia', 'Surabaya', 'SUB'],
      ['Indonesia', 'Yogyakarta', 'JOG'],
      ['Indonesia', 'Pontianak', 'PNK'],
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
