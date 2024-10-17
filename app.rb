require 'sinatra'
require 'sinatra/reloader'
require 'slim'

get ('/one/:number') do
    @data = params[:number].to_i
    slim :one
end


get ('/two') do
    @lista = ["gurka", "majs", "sallad", "paprika"]
    slim :two
end