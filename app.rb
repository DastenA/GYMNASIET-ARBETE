require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'rubygems'
require 'rmagick'

require 'rmagick'

# Ladda bilden
image = Magick::Image.read('vit.jpg').first

# Gå igenom varje pixel och ändra dess värden
image.each_pixel do |pixel, x, y|
  # Ändra värden och klipp till intervallet [0, 255]
  red   = [[pixel.red / 256 - 100, 0].max, 255].min
  green = [[pixel.green / 256 - 100, 0].max, 255].min
  blue  = [[pixel.blue / 256 - 100, 0].max, 255].min

  # Uppdatera pixeln
  image.pixel_color(x, y, Magick::Pixel.new(red * 256, green * 256, blue * 256))
end

# Spara den ändrade bilden
image.write('output_image.jpg')
puts "Bilden har sparats som output_image.jpg"

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