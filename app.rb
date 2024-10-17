require 'sinatra'
require 'sinatra/reloader'
require 'slim'

get ('/one') do
    slim :one
end


get ('/two') do
    slim :two
end