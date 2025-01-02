#flera rader. inte bara första raden som går att kryptera

require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'rubygems'
require 'rmagick'
enable :sessions

#--------------- Kryptera sidan

#Läsa av meddelande när man skriver in ett meddelande och returnerar en array av rgb värden från bilden
def array_name_pixels_from_image(bild)
    image = Magick::Image.read(bild).first

    rgb_values = []

    image.rows.times do |y|
    row = []
    image.columns.times do |x|
        pixel = image.pixel_color(x, y)
        r = (pixel.red / 257).to_i
        g = (pixel.green / 257).to_i
        b = (pixel.blue / 257).to_i
        row << [r, g, b]
    end
    rgb_values << row
    end
    
    return rgb_values

end

#från en rgb array av start bilden till en binär array
def to_binary(pixels)

    binary_pixels = pixels.map do |row|
        row.map do |(r, g, b)|
          [
            r.to_s(2).rjust(8, '0'), 
            g.to_s(2).rjust(8, '0'), 
            b.to_s(2).rjust(8, '0') 
          ]
        end
    end

    return binary_pixels

end

def arbirr(i)

    boboo = ""

    while i < 10000
        boboo << "a"
    end

    return boboo

end

#ändrar på binära talen arrayen från det hemliga meddelandet som skrivits
def arne(pixel_array, data, bred, hog)

    array_of_bini_from_text = []
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
    a = 0
    k = 7
    bob = false

    while i < array_of_bini_from_text.length

        if array_of_bini_from_text[i] == "01111100"
            array_of_bini_from_text[i] = "00000000"
        end

        if z == bred || z == (bred - 1)

            if array_of_bini_from_text[i].length == 8 

                z = 0
                a += 1 
                b = 0
                bob = false

                if a - 1 == hog

                    k -=1
                    a = 0

                    if k < 0
                        raise "för långt meddelande"
                    end

                end
            end
        end

        if array_of_bini_from_text[i].length == 8 || array_of_bini_from_text[i].length == 5 || array_of_bini_from_text[i].length == 2 
            if bob == true
                z += 1
                b = 0  

            end
        end

        bob = true

        pixel_array[a][z][b][k] = array_of_bini_from_text[i][0] 
        array_of_bini_from_text[i].slice!(0)
    
        if array_of_bini_from_text[i].length == 0
            i +=1
        end
        b += 1
    
    end

    return pixel_array

end

#från en binär array av start bilden till en rgb array
def to_rgb(pixels)
    rgb_pixels = pixels.map do |row|
      row.map do |(r_bin, g_bin, b_bin)|
        [
          r_bin.to_i(2),
          g_bin.to_i(2), 
          b_bin.to_i(2) 
        ]
      end
    end
  
    return rgb_pixels
end

#skapar en bild av ändrade pixlar array och skriver ut en krypterad bild i dekryptera mappen 
def from_pixels_to_image(pixels)

    height = pixels.length
    width = pixels[0].length
  
    image = Magick::Image.new(width, height)
  
    pixel_array = pixels.flatten(1).map do |(r, g, b)|
      Magick::Pixel.new(r * 257, g * 257, b * 257) # Skala till 16-bitars
    end
  
    image.store_pixels(0, 0, width, height, pixel_array)
  
    image.write("./public/img/dekryptera/krypterad_#{session[:session_kryptera_img_2]}.png")
end

#------------------------- Dekryptera sidan

#läsa bilden på dekryptera sidan
def read_image(image)
    image = Magick::Image.read(image).first
  
    rgb_values = Array.new(image.rows) { Array.new(image.columns) }
      
    image.rows.times do |y|
        image.columns.times do |x|
        pixel = image.pixel_color(x, y)
    
        r = (pixel.red / 257).to_i
        g = (pixel.green / 257).to_i
        b = (pixel.blue / 257).to_i
    
        rgb_values[y][x] = [r, g, b]
        end
    end

    return rgb_values

end

#Hitta meddelandet från en binär array
def hitta_meddelandet_from_binary_array(array)
    
    x = 0
    u = -1
    long_messege = []

    while x < array.length
        messege = ""
        j = 0
        y = 0

        while j < 8 
            if j == 3 || j == 6 || j == 0
                u += 1
                y = 0
            end
            messege << array[0][u][y][7]
            j +=1
            y += 1
        end

        if messege == "00000000"
            x = array.length
        else
            long_messege << messege
            x += 1
        end

    end

    i = 0
    while i < long_messege.length
        long_messege[i] = ascii_revert(long_messege[i])
        i += 1
    end
    result_message = ""
    i = 0

    while i < long_messege.length

        result_message << long_messege[i]
        i += 1
    end
    session[:result_message] = result_message

    return result_message

end

#ett tecken från det hemliga meddelandet görs om till binära tal. om ett tecken inte finns fungerar inte programet och det avbryts
def ascii(element)

    new_element = nil
  
    case element
    when " " then new_element = "00100000"
    when "!" then new_element = "00100001"
    when "\"" then new_element = "00100010"
    when "#" then new_element = "00100011"
    when "$" then new_element = "00100100"
    when "%" then new_element = "00100101"
    when "&" then new_element = "00100110"
    when "'" then new_element = "00100111"
    when "(" then new_element = "00101000"
    when ")" then new_element = "00101001"
    when "*" then new_element = "00101010"
    when "+" then new_element = "00101011"
    when "," then new_element = "00101100"
    when "-" then new_element = "00101101"
    when "." then new_element = "00101110"
    when "/" then new_element = "00101111"
    when "0" then new_element = "00110000"
    when "1" then new_element = "00110001"
    when "2" then new_element = "00110010"
    when "3" then new_element = "00110011"
    when "4" then new_element = "00110100"
    when "5" then new_element = "00110101"
    when "6" then new_element = "00110110"
    when "7" then new_element = "00110111"
    when "8" then new_element = "00111000"
    when "9" then new_element = "00111001"
    when ":" then new_element = "00111010"
    when ";" then new_element = "00111011"
    when "<" then new_element = "00111100"
    when "=" then new_element = "00111101"
    when ">" then new_element = "00111110"
    when "?" then new_element = "00111111"
    when "@" then new_element = "01000000"
    when "A" then new_element = "01000001"
    when "B" then new_element = "01000010"
    when "C" then new_element = "01000011"
    when "D" then new_element = "01000100"
    when "E" then new_element = "01000101"
    when "F" then new_element = "01000110"
    when "G" then new_element = "01000111"
    when "H" then new_element = "01001000"
    when "I" then new_element = "01001001"
    when "J" then new_element = "01001010"
    when "K" then new_element = "01001011"
    when "L" then new_element = "01001100"
    when "M" then new_element = "01001101"
    when "N" then new_element = "01001110"
    when "O" then new_element = "01001111"
    when "P" then new_element = "01010000"
    when "Q" then new_element = "01010001"
    when "R" then new_element = "01010010"
    when "S" then new_element = "01010011"
    when "T" then new_element = "01010100"
    when "U" then new_element = "01010101"
    when "V" then new_element = "01010110"
    when "W" then new_element = "01010111"
    when "X" then new_element = "01011000"
    when "Y" then new_element = "01011001"
    when "Z" then new_element = "01011010"
    when "[" then new_element = "01011011"
    when "\\" then new_element = "01011100"
    when "]" then new_element = "01011101"
    when "^" then new_element = "01011110"
    when "_" then new_element = "01011111"
    when "`" then new_element = "01100000"
    when "a" then new_element = "01100001"
    when "b" then new_element = "01100010"
    when "c" then new_element = "01100011"
    when "d" then new_element = "01100100"
    when "e" then new_element = "01100101"
    when "f" then new_element = "01100110"
    when "g" then new_element = "01100111"
    when "h" then new_element = "01101000"
    when "i" then new_element = "01101001"
    when "j" then new_element = "01101010"
    when "k" then new_element = "01101011"
    when "l" then new_element = "01101100"
    when "m" then new_element = "01101101"
    when "n" then new_element = "01101110"
    when "o" then new_element = "01101111"
    when "p" then new_element = "01110000"
    when "q" then new_element = "01110001"
    when "r" then new_element = "01110010"
    when "s" then new_element = "01110011"
    when "t" then new_element = "01110100"
    when "u" then new_element = "01110101"
    when "v" then new_element = "01110110"
    when "w" then new_element = "01110111"
    when "x" then new_element = "01111000"
    when "y" then new_element = "01111001"
    when "z" then new_element = "01111010"
    when "{" then new_element = "01111011"
    when "}" then new_element = "01111101"
    when "~" then new_element = "01111110"
    when "å" then new_element = "11100101"
    when "ä" then new_element = "11100100"
    when "ö" then new_element = "11110110"
    when "Å" then new_element = "11000101"
    when "Ä" then new_element = "11000100"
    when "Ö" then new_element = "11010110"
    when "|" then new_element = "01111100"
    else
        raise "Kan inte tolka #{element}"
    end

    return new_element

end

#När man har en stor array med massa rgb värden som gjorts till binära tal tar man de sista nummrarna i varje binära tal och adderar ihop tills man får 8 tal. sen kör man denna funktion så man får fram ett meddelande. om ett binärt tal inte finns fungerar inte programet och det avbryts
def ascii_revert(element)

    new_element = nil
  
    case element
    when "00100000" then new_element = " "
    when "00100001" then new_element = "!"
    when "00100010" then new_element = "\""
    when "00100011" then new_element = "#"
    when "00100100" then new_element = "$"
    when "00100101" then new_element = "%"
    when "00100110" then new_element = "&"
    when "00100111" then new_element = "'"
    when "00101000" then new_element = "("
    when "00101001" then new_element = ")"
    when "00101010" then new_element = "*"
    when "00101011" then new_element = "+"
    when "00101100" then new_element = ","
    when "00101101" then new_element = "-"
    when "00101110" then new_element = "."
    when "00101111" then new_element = "/"
    when "00110000" then new_element = "0"
    when "00110001" then new_element = "1"
    when "00110010" then new_element = "2"
    when "00110011" then new_element = "3"
    when "00110100" then new_element = "4"
    when "00110101" then new_element = "5"
    when "00110110" then new_element = "6"
    when "00110111" then new_element = "7"
    when "00111000" then new_element = "8"
    when "00111001" then new_element = "9"
    when "00111010" then new_element = ":"
    when "00111011" then new_element = ";"
    when "00111100" then new_element = "<"
    when "00111101" then new_element = "="
    when "00111110" then new_element = ">"
    when "00111111" then new_element = "?"
    when "01000000" then new_element = "@"
    when "01000001" then new_element = "A"
    when "01000010" then new_element = "B"
    when "01000011" then new_element = "C"
    when "01000100" then new_element = "D"
    when "01000101" then new_element = "E"
    when "01000110" then new_element = "F"
    when "01000111" then new_element = "G"
    when "01001000" then new_element = "H"
    when "01001001" then new_element = "I"
    when "01001010" then new_element = "J"
    when "01001011" then new_element = "K"
    when "01001100" then new_element = "L"
    when "01001101" then new_element = "M"
    when "01001110" then new_element = "N"
    when "01001111" then new_element = "O"
    when "01010000" then new_element = "P"
    when "01010001" then new_element = "Q"
    when "01010010" then new_element = "R"
    when "01010011" then new_element = "S"
    when "01010100" then new_element = "T"
    when "01010101" then new_element = "U"
    when "01010110" then new_element = "V"
    when "01010111" then new_element = "W"
    when "01011000" then new_element = "X"
    when "01011001" then new_element = "Y"
    when "01011010" then new_element = "Z"
    when "01011011" then new_element = "["
    when "01011100" then new_element = "\\"
    when "01011101" then new_element = "]"
    when "01011110" then new_element = "^"
    when "01011111" then new_element = "_"
    when "01100000" then new_element = "`"
    when "01100001" then new_element = "a"
    when "01100010" then new_element = "b"
    when "01100011" then new_element = "c"
    when "01100100" then new_element = "d"
    when "01100101" then new_element = "e"
    when "01100110" then new_element = "f"
    when "01100111" then new_element = "g"
    when "01101000" then new_element = "h"
    when "01101001" then new_element = "i"
    when "01101010" then new_element = "j"
    when "01101011" then new_element = "k"
    when "01101100" then new_element = "l"
    when "01101101" then new_element = "m"
    when "01101110" then new_element = "n"
    when "01101111" then new_element = "o"
    when "01110000" then new_element = "p"
    when "01110001" then new_element = "q"
    when "01110010" then new_element = "r"
    when "01110011" then new_element = "s"
    when "01110100" then new_element = "t"
    when "01110101" then new_element = "u"
    when "01110110" then new_element = "v"
    when "01110111" then new_element = "w"
    when "01111000" then new_element = "x"
    when "01111001" then new_element = "y"
    when "01111010" then new_element = "z"
    when "01111011" then new_element = "{"
    when "01111100" then new_element = "|"
    when "01111101" then new_element = "}"
    when "01111110" then new_element = "~"
    when "11100101" then new_element = "å"
    when "11100100" then new_element = "ä"
    when "11110110" then new_element = "ö"
    when "11000101" then new_element = "Å"
    when "11000100" then new_element = "Ä"
    when "11010110" then new_element = "Ö"
    end
  
    return new_element

end

#Kryptera sidan
get ('/kryptera') do
    slim :kryptera
end

#Om man skriver ett meddelande på kryptera sidan och klickar på enter
post ('/kryptera_post') do

    data = params[:secret_one]#sparar det hemliga meddelandet i data
    session[:session_meddelande] = data#spara i session

    data = arbirr(0)
    data = data + "|"#lägger till tecknet | på det hemlig medelandet. detta görs för att denna görs till inära tal och sen göra den om till det binära talet "00000000" detta är värdet nil. då vet man när man dekrypterar medelandet att meddeladnet är slut. varför tecknet | är för att ingen avändet |

    #hittar bilden man valde och gör en rgb array av den
    pixel_array = array_name_pixels_from_image("./public/img/kryptera/#{session[:session_kryptera_img]}")

    #gör om denna array till binära tal
    pixel_array = to_binary(pixel_array)
    
    bred = pixel_array[0].length
    bred = ((bred) - 1)

    hog = pixel_array.length
    hog = ((hog) - 1)

    #ändar på binära arrayen
    pixel_array = arne(pixel_array, data, bred, hog)

    #gör den ändrade binära arrayen till en rgb array
    pixel_array = to_rgb(pixel_array)

    #skapar en bild av denna ändrade rgb array
    from_pixels_to_image(pixel_array)

    redirect('/kryptera')

end

#Om man byter bild på kryptera sidan och sedan klickar på enter
post ('/kryptera_img') do

    @data = params[:img_kryptera]#en string av filvägen till den bild man väljer
    session[:session_kryptera_img] = @data#sparar i session
    session[:session_kryptera_img_2] = @data[0...-4]#tar bort de sista 4 sista teckten från filvägen. alltså antingen .jpg eller .png. detta för att kunna spara bilden som en png från en jpg
    
    redirect('/kryptera')

end

#Dekryptera sidan
get ('/dekryptera') do
    slim :dekryptera
end

#Om man skriver lösenordet på dekryptera sidan och sedan klickar på enter
post ('/dekryptera_post') do

    password = "Amogus"#Lösenordet för att kunna dekryptera sidan
    session[:cor_password] = false #sätter en varibel till false. den görs til true om lösenordet är fel och det står fel lösenord
    @data= params[:secret_two]#hämtar en string av de använderen skriver in som lösenord
    session[:session_password] = @data #sparar till en session

    #om lösenordet är rätt ska man hitta meddelandet i bilden
    if @data == password

        #läsa in bilden till rgb värden till mallus_array
        array = read_image("./public/img/dekryptera/#{session[:session_dekryptera_img]}")
      
        #mallus arrayen med rgb görs om till binära tal iställer för rgb värden
        array = to_binary(array)

        #------------

        #läsa av alla sista nummer på alla binära tal pixlar för att hitta och skapa meddelandet. när man har en stor array med massa rgb värden som gjorts till binära tal tar man de sista nummrarna i varje binära tal och adderar ihop tills man får 8 tal. sen printas detta ut i terminalen
        system('cls')
        puts ""
        puts ""        
        puts hitta_meddelandet_from_binary_array(array)
        puts ""
        puts "" 

    #om lösenordet är fel ska det stå fel lösenord och man skickas direkt tillbaka till sidan
    else
        session[:cor_password] = true
        redirect('/dekryptera')
    end
    
    redirect('/dekryptera')

end

#Om man väljer bild på dekryptera sidan och seden klickar på enter
post ('/dekryptera_img') do

    @data = params[:img_dekryptera]#en string av filvägen till den bild man väljer
    session[:session_dekryptera_img] = @data#sparar i session

    redirect('/dekryptera')

end