require 'sinatra'
require 'sinatra/reloader'
require 'slim'

post ('/one_p') do
    @data_one = params[:secret_one]
    p @data_one
    redirect('/one')

end

get ('/one') do

    slim :one

end

post ('/two_p') do
    @data_two = params[:secret_two]
    p @data_two
    redirect('/two')
end

get ('/two') do
    slim :two
end