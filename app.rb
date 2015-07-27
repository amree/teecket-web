require "sinatra/base"
require 'sinatra/partial'
require "tilt/erubis"
require "teecket"
require "net/http"

require_relative "helpers"

class App < Sinatra::Base
  register Sinatra::Partial
  helpers Sinatra::Teecket::Helpers

  enable :logging

  set :partial_template_engine, :erb

  before do
    @params    = params
    @flights   = []
    @errors    = []
    @countries = airports.group_by { |country| country.first }
  end

  get '/' do
    index
  end

  get '/:from/:to/:date' do
    index
  end

  post '/hooks/telegram' do
    json = JSON.parse(request.body.read)
    sender_id = json["message"]["from"]["id"]

    from, to, date = if json["message"]["text"]
                       json["message"]["text"].split(" ")
                     else
                       ['', '', '']
                     end

    validate(from, to, date)

    if @errors.empty?
      search(from, to, date)

      message = erb :telegram, layout: false
    else
      message = "Try this format: KUL KBR 31-12-2015"
    end

    sendTelegramMessage(sender_id, message)
    ""
  end

  get '/announcements' do
    erb :announcements
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

  def sendTelegramMessage(receiver, message)
    uri = URI.parse("https://api.telegram.org/bot#{ENV['TG_API']}/sendMessage")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({ chat_id: receiver, text: message })

    http.request(request)
  end

  run! if app_file == $0
end
