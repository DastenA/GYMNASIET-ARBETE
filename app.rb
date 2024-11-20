require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'minimagick'
enable :sessions

#kryptera

get ('/kryptera') do
    slim :kryptera

end

post ('/kryptera_post') do
    @data = params[:secret_one]
    session[:session_meddelande] = @data
    redirect('/kryptera')

end

post ('/kryptera_img') do
    @data = params[:img_kryptera]
    session[:session_kryptera_img] = @data
    redirect('/kryptera')
end

#dekryptera

get ('/dekryptera') do
    slim :dekryptera
end

post ('/dekryptera_post') do
    @data= params[:secret_two]
    session[:session_password] = @data
    redirect('/dekryptera')
end

post ('/dekryptera_img') do
    @data = params[:img_dekryptera]
    session[:session_dekryptera_img] = @data
    redirect('/dekryptera')
end