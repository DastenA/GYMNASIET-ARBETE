require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'rubygems'
require 'rmagick'
enable :sessions


#chat gpt
def from_pixels_to_image(pixels)

    # Få bredd och höjd från pixel-arrayen
  height = pixels.length
  width = pixels[0].length

  # Skapa en ny bild med rätt dimensioner
  image = Magick::Image.new(width, height)

  # Skapa en array för pixlar
  pixel_array = []

  # Loopa genom varje rad och kolumn i pixel-arrayen
  pixels.each do |row|
    row.each do |(r, g, b)|
      # Konvertera 8-bitars RGB-värden till 16-bitars
      pixel_array << Magick::Pixel.new(r * 257, g * 257, b * 257)
    end
  end

  # Kontrollera att pixel-arrayen har rätt storlek
  if pixel_array.size != width * height
    raise "Pixel-arrayens storlek matchar inte bildens dimensioner!"
  end

  # Sätt pixlarna i bilden
  image.store_pixels(0, 0, width, height, pixel_array)

  # Validera resultat
  exported_pixels = image.export_pixels(0, 0, width, height, "RGB")
  puts "Exported pixels: #{exported_pixels.map { |v| v / 257 }.each_slice(3).to_a.inspect}"

  # Skriv ut bilden till fil
  image.write("/public/img/kryptera/output_#{session[:session_kryptera_img]}.jpg")
  puts "Bilden har sparats som 'lol.jpg'."
end
  


#chat gpt
def array_name_pixels_from_image(bild)
    p bild
    image = Magick::Image.read(bild).first # Byt ut "image_path.jpg" mot bildens filväg

    # Array för att lagra RGB-värden
    rgb_values = []

    # Iterera genom varje rad och pixel
    image.rows.times do |y|
    row = []
    image.columns.times do |x|
        pixel = image.pixel_color(x, y)
        # Hämta RGB-värden och normalisera till 0-255 (RMagick använder 16-bitars färgdjup)
        r = (pixel.red / 257).to_i
        g = (pixel.green / 257).to_i
        b = (pixel.blue / 257).to_i
        row << [r, g, b]
    end
    rgb_values << row
    end

    # rgb_values innehåller nu alla RGB-värde
    
    return rgb_values

end

#chat gpt
def to_rgb(pixels)
    rgb_pixels = pixels.map do |row|
      row.map do |(r_bin, g_bin, b_bin)|
        [
          r_bin.to_i(2), # Konvertera från binärt till heltal för röd kanal
          g_bin.to_i(2), # Konvertera från binärt till heltal för grön kanal
          b_bin.to_i(2)  # Konvertera från binärt till heltal för blå kanal
        ]
      end
    end
  
    return rgb_pixels
end

#chat gpt
def to_binary(pixels)

    binary_pixels = pixels.map do |row|
        row.map do |(r, g, b)|
          [
            r.to_s(2).rjust(8, '0'), # Röd kanal i binärt
            g.to_s(2).rjust(8, '0'), # Grön kanal i binärt
            b.to_s(2).rjust(8, '0')  # Blå kanal i binärt
          ]
        end
    end

    return binary_pixels

end

def ascii(element)

    new_element = 0
    
    case element
    when "a"
        new_element = "01100001"
    when "b"
        new_element = "01100010"
    when "c"
        new_element = "01100011"
    when "d"
        new_element = "01100100"
    when "e"
        new_element = "01100101"
    when "f"
        new_element = "01100110"
    when "g"
        new_element = "01100111"
    when "h"
        new_element = "01101000"
    when "i"
        new_element = "01101001"
    when "j"
        new_element = "01101010"
    when "k"
        new_element = "01101011"
    when "l"
        new_element = "01101100"
    when "m"
        new_element = "01101101"
    when "n"
        new_element = "01101110"
    when "o"
        new_element = "01101111"
    when "p"
        new_element = "01110000"
    when "q"
        new_element = "01110001"
    when "r"
        new_element = "01110010"
    when "s"
        new_element = "01110011"
    when "t"
        new_element = "01110100"
    when "u"
        new_element = "01110101"
    when "v"
        new_element = "01110110"
    when "w"
        new_element = "01110111"
    when "x"
        new_element = "01111000"
    when "y"
        new_element = "01111001"
    when "z"
        new_element = "01111010"
    else
        new_element = nil
        raise "kan inte skriva #{element}"
    end

end

get ('/kryptera') do
    slim :kryptera

end

post ('/kryptera_post') do

    array_of_bini_from_text = []

    data = params[:secret_one]
    session[:session_meddelande] = data

    pixel_array = array_name_pixels_from_image("/public/img/kryptera/#{session[:session_kryptera_img]}")
    p pixel_array[0]
    pixel_array = to_binary(pixel_array)

    i = 0
    while i < data.length

        bini = ascii(data[i])

        array_of_bini_from_text << bini

        i+=1
    end

    #------------------

    i = 0
    z = 0
    b = 0
    bob = false

    while i < array_of_bini_from_text.length

        if array_of_bini_from_text[i].length == 8 || array_of_bini_from_text[i].length == 5 || array_of_bini_from_text[i].length == 2 
          
            if bob == true
                z += 1
                b = 0  

            end
        end

        bob = true

        pixel_array[0][z][b][7] = array_of_bini_from_text[i][0] 
        array_of_bini_from_text[i].slice!(0)

                
        if array_of_bini_from_text[i].length == 0
            i +=1
        end
        b += 1
    end

    #------

    pixel_arrayo = to_rgb(pixel_array)
    from_pixels_to_image(pixel_arrayo)

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