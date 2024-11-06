require 'sinatra'
require 'sinatra/reloader'
require 'slim'
enable :sessions

post ('/one_p') do
    @data_one = params[:secret_one]
    redirect('/one')

end

get ('/one') do
    slim :one
end

post ('/two_p') do
    @data_two = params[:secret_two]
    session[:var_two] = @data_two
    
    redirect('/two')
end

get ('/two') do
    slim :two
end