require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'rubygems'
require 'rmagick'
enable :sessions

def generate_random_characters(x)

    random_characters = []

    characters = [
      " ", "!", "#", "$", "%", "&", "'", "(", ")"
    ]
  
    x.times do
      random_characters << characters.sample
    end
  
    return random_characters.join
end

#------------------------ Kryptera sidan

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

def arne(pixel_array, data, bred, hog)

    varv = 1

    puts ""
    puts "varv #{varv}"
    puts ""

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

                if (a - 1) == hog

                    k -=1
                    a = 0

                    varv += 1

                    if k < 0
                        raise "för långt meddelande"
                    end
                    
                    puts ""
                    puts "varv #{varv}"
                    puts ""

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

def from_pixels_to_image(pixels)

    height = pixels.length
    width = pixels[0].length
  
    image = Magick::Image.new(width, height)
  
    pixel_array = pixels.flatten(1).map do |(r, g, b)|
      Magick::Pixel.new(r * 257, g * 257, b * 257)
    end
  
    image.store_pixels(0, 0, width, height, pixel_array)
  
    image.write("./public/img/dekryptera/krypterad_#{session[:session_kryptera_img_2]}.png")
end

#------------------------ Dekryptera sidan

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

def hitta_meddelandet_from_binary_array(array,bred,hog)

    stop = false
    x = 0
    u = 0
    b = 7
    k = 0
    bob = false

    long_message = []

    while b != nil

        messege = ""
        j = 0
        y = 0
        if u == bred || u == (bred - 1)

            k += 1

            if k == (hog + 1)

                k = 0

                b -= 1

                if b == (-1)
                    b = nil
                end

            end

            u = 0
            bob = false

        end

        if b != nil

            while j < 8 
                if j == 3 || j == 6 || j == 0
                    if bob == true

                        u += 1
                        y = 0
                    end
                end
                bob = true
        
                messege << array[k][u][y][b]
                j +=1
                y += 1
            end
            if messege == "00000000"
                b = nil
            else
                long_message << messege
            end
        end

    end

    i = 0
    while i < long_message.length
        long_message[i] = ascii_revert(long_message[i])
        i += 1
    end
    result_message = ""
    i = 0


    while i < long_message.length
        result_message << long_message[i]
        i += 1
    end
    session[:result_message] = result_message

    return result_message

end

def ascii(element)

    new_element = nil
  
    case element
    when "#" then new_element = "00100011"
    when " " then new_element = "00100000"
    when "!" then new_element = "00100001"
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
    when "€" then new_element = "10000000"
    when "ƒ" then new_element = "10000011"
    when "„" then new_element = "10000100"
    when "…" then new_element = "10000101"
    when "†" then new_element = "10000110"
    when "‡" then new_element = "10000111"
    when "‰" then new_element = "10001001"
    when "Š" then new_element = "10001010"
    when "Œ" then new_element = "10001100"
    when "Ž" then new_element = "10001110"
    when "“" then new_element = "10010011"
    when "”" then new_element = "10010100"
    when "•" then new_element = "10010101"
    when "—" then new_element = "10010111"
    when "™" then new_element = "10011001"
    when "š" then new_element = "10011010"
    when "œ" then new_element = "10011100"
    when "ž" then new_element = "10011110"
    when "Ÿ" then new_element = "10011111"
    when "¡" then new_element = "10100001"
    when "¢" then new_element = "10100010"
    when "£" then new_element = "10100011"
    when "¤" then new_element = "10100100"
    when "¥" then new_element = "10100101"
    when "¦" then new_element = "10100110"
    when "§" then new_element = "10100111"
    when "¨" then new_element = "10101000"
    when "©" then new_element = "10101001"
    when "ª" then new_element = "10101010"
    when "«" then new_element = "10101011"
    when "¬" then new_element = "10101100"
    when "®" then new_element = "10101110"
    when "¯" then new_element = "10101111"
    when "°" then new_element = "10110000"
    when "±" then new_element = "10110001"
    when "²" then new_element = "10110010"
    when "³" then new_element = "10110011"
    when "µ" then new_element = "10110101"
    when "¶" then new_element = "10110110"
    when "·" then new_element = "10110111"
    when "¹" then new_element = "10111001"
    when "º" then new_element = "10111010"
    when "»" then new_element = "10111011"
    when "¼" then new_element = "10111100"
    when "½" then new_element = "10111101"
    when "¾" then new_element = "10111110"
    when "¿" then new_element = "10111111"
    when "À" then new_element = "11000000"
    when "Á" then new_element = "11000001"
    when "Â" then new_element = "11000010"
    when "Ã" then new_element = "11000011"
    when "Ä" then new_element = "11000100"
    when "Å" then new_element = "11000101"
    when "Æ" then new_element = "11000110"
    when "Ç" then new_element = "11000111"
    when "È" then new_element = "11001000"
    when "É" then new_element = "11001001"
    when "Ê" then new_element = "11001010"
    when "Ë" then new_element = "11001011"
    when "Ì" then new_element = "11001100"
    when "Í" then new_element = "11001101"
    when "Î" then new_element = "11001110"
    when "Ï" then new_element = "11001111"
    when "Ð" then new_element = "11010000"
    when "Ñ" then new_element = "11010001"
    when "Ò" then new_element = "11010010"
    when "Ó" then new_element = "11010011"
    when "Ô" then new_element = "11010100"
    when "Õ" then new_element = "11010101"
    when "Ö" then new_element = "11010110"
    when "Ø" then new_element = "11011000"
    when "Ù" then new_element = "11011001"
    when "Ú" then new_element = "11011010"
    when "Û" then new_element = "11011011"
    when "Ü" then new_element = "11011100"
    when "Ý" then new_element = "11011101"
    when "Þ" then new_element = "11011110"
    when "ß" then new_element = "11011111"
    when "à" then new_element = "11100000"
    when "á" then new_element = "11100001"
    when "â" then new_element = "11100010"
    when "ã" then new_element = "11100011"
    when "ä" then new_element = "11100100"
    when "å" then new_element = "11100101"
    when "æ" then new_element = "11100110"
    when "ç" then new_element = "11100111"
    when "è" then new_element = "11101000"
    when "é" then new_element = "11101001"
    when "ê" then new_element = "11101010"
    when "ë" then new_element = "11101011"
    when "ì" then new_element = "11101100"
    when "í" then new_element = "11101101"
    when "î" then new_element = "11101110"
    when "ï" then new_element = "11101111"
    when "ð" then new_element = "11110000"
    when "ñ" then new_element = "11110001"
    when "ò" then new_element = "11110010"
    when "ó" then new_element = "11110011"
    when "ô" then new_element = "11110100"
    when "õ" then new_element = "11110101"
    when "ö" then new_element = "11110110"
    when "÷" then new_element = "11110111"
    when "ø" then new_element = "11111000"
    when "ù" then new_element = "11111001"
    when "ú" then new_element = "11111010"
    when "û" then new_element = "11111011"
    when "ü" then new_element = "11111100"
    when "ý" then new_element = "11111101"
    when "þ" then new_element = "11111110"
    when "ÿ" then new_element = "11111111"

    when "|" then new_element = "01111100"


    else
        raise "Kan inte tolka #{element}"
    end

    return new_element

end

def ascii_revert(binary)

    new_char = nil
  
    case binary
    when "01111100" then new_char = "|"

    when "00100000" then new_char = " "
    when "00100001" then new_char = "!"
    when "00100011" then new_char = "#"
    when "00100100" then new_char = "$"
    when "00100101" then new_char = "%"
    when "00100110" then new_char = "&"
    when "00100111" then new_char = "'"
    when "00101000" then new_char = "("
    when "00101001" then new_char = ")"
    when "00101010" then new_char = "*"
    when "00101011" then new_char = "+"
    when "00101100" then new_char = ","
    when "00101101" then new_char = "-"
    when "00101110" then new_char = "."
    when "00101111" then new_char = "/"
    when "00110000" then new_char = "0"
    when "00110001" then new_char = "1"
    when "00110010" then new_char = "2"
    when "00110011" then new_char = "3"
    when "00110100" then new_char = "4"
    when "00110101" then new_char = "5"
    when "00110110" then new_char = "6"
    when "00110111" then new_char = "7"
    when "00111000" then new_char = "8"
    when "00111001" then new_char = "9"
    when "00111010" then new_char = ":"
    when "00111011" then new_char = ";"
    when "00111100" then new_char = "<"
    when "00111101" then new_char = "="
    when "00111110" then new_char = ">"
    when "00111111" then new_char = "?"
    when "01000000" then new_char = "@"
    when "01000001" then new_char = "A"
    when "01000010" then new_char = "B"
    when "01000011" then new_char = "C"
    when "01000100" then new_char = "D"
    when "01000101" then new_char = "E"
    when "01000110" then new_char = "F"
    when "01000111" then new_char = "G"
    when "01001000" then new_char = "H"
    when "01001001" then new_char = "I"
    when "01001010" then new_char = "J"
    when "01001011" then new_char = "K"
    when "01001100" then new_char = "L"
    when "01001101" then new_char = "M"
    when "01001110" then new_char = "N"
    when "01001111" then new_char = "O"
    when "01010000" then new_char = "P"
    when "01010001" then new_char = "Q"
    when "01010010" then new_char = "R"
    when "01010011" then new_char = "S"
    when "01010100" then new_char = "T"
    when "01010101" then new_char = "U"
    when "01010110" then new_char = "V"
    when "01010111" then new_char = "W"
    when "01011000" then new_char = "X"
    when "01011001" then new_char = "Y"
    when "01011010" then new_char = "Z"
    when "01011011" then new_char = "["
    when "01011101" then new_char = "]"
    when "01011110" then new_char = "^"
    when "01011111" then new_char = "_"
    when "01100000" then new_char = "`"
    when "01100001" then new_char = "a"
    when "01100010" then new_char = "b"
    when "01100011" then new_char = "c"
    when "01100100" then new_char = "d"
    when "01100101" then new_char = "e"
    when "01100110" then new_char = "f"
    when "01100111" then new_char = "g"
    when "01101000" then new_char = "h"
    when "01101001" then new_char = "i"
    when "01101010" then new_char = "j"
    when "01101011" then new_char = "k"
    when "01101100" then new_char = "l"
    when "01101101" then new_char = "m"
    when "01101110" then new_char = "n"
    when "01101111" then new_char = "o"
    when "01110000" then new_char = "p"
    when "01110001" then new_char = "q"
    when "01110010" then new_char = "r"
    when "01110011" then new_char = "s"
    when "01110100" then new_char = "t"
    when "01110101" then new_char = "u"
    when "01110110" then new_char = "v"
    when "01110111" then new_char = "w"
    when "01111000" then new_char = "x"
    when "01111001" then new_char = "y"
    when "01111010" then new_char = "z"
    when "01111011" then new_char = "{"
    when "01111101" then new_char = "}"
    when "01111110" then new_char = "~"
    when "10000000" then new_char = "€"
    when "10000011" then new_char = "ƒ"
    when "10000100" then new_char = "„"
    when "10000101" then new_char = "…"
    when "10000110" then new_char = "†"
    when "10000111" then new_char = "‡"
    when "10001001" then new_char = "‰"
    when "10001010" then new_char = "Š"
    when "10001100" then new_char = "Œ"
    when "10001110" then new_char = "Ž"
    when "10010011" then new_char = "“"
    when "10010100" then new_char = "”"
    when "10010101" then new_char = "•"
    when "10010111" then new_char = "—"
    when "10011001" then new_char = "™"
    when "10011010" then new_char = "š"
    when "10011100" then new_char = "œ"
    when "10011110" then new_char = "ž"
    when "10011111" then new_char = "Ÿ"
    when "10100001" then new_char = "¡"
    when "10100010" then new_char = "¢"
    when "10100011" then new_char = "£"
    when "10100100" then new_char = "¤"
    when "10100101" then new_char = "¥"
    when "10100110" then new_char = "¦"
    when "10100111" then new_char = "§"
    when "10101000" then new_char = "¨"
    when "10101001" then new_char = "©"
    when "10101010" then new_char = "ª"
    when "10101011" then new_char = "«"
    when "10101100" then new_char = "¬"
    when "10101110" then new_char = "®"
    when "10101111" then new_char = "¯"
    when "10110000" then new_char = "°"
    when "10110001" then new_char = "±"
    when "10110010" then new_char = "²"
    when "10110011" then new_char = "³"
    when "10110101" then new_char = "µ"
    when "10110110" then new_char = "¶"
    when "10110111" then new_char = "·"
    when "10111001" then new_char = "¹"
    when "10111010" then new_char = "º"
    when "10111011" then new_char = "»"
    when "10111100" then new_char = "¼"
    when "10111101" then new_char = "½"
    when "10111110" then new_char = "¾"
    when "10111111" then new_char = "¿"
    when "11000000" then new_char = "À"
    when "11000001" then new_char = "Á"
    when "11000010" then new_char = "Â"
    when "11000011" then new_char = "Ã"
    when "11000100" then new_char = "Ä"
    when "11000101" then new_char = "Å"
    when "11000110" then new_char = "Æ"
    when "11000111" then new_char = "Ç"
    when "11001000" then new_char = "È"
    when "11001001" then new_char = "É"
    when "11001010" then new_char = "Ê"
    when "11001011" then new_char = "Ë"
    when "11001100" then new_char = "Ì"
    when "11001101" then new_char = "Í"
    when "11001110" then new_char = "Î"
    when "11001111" then new_char = "Ï"
    when "11010000" then new_char = "Ð"
    when "11010001" then new_char = "Ñ"
    when "11010010" then new_char = "Ò"
    when "11010011" then new_char = "Ó"
    when "11010100" then new_char = "Ô"
    when "11010101" then new_char = "Õ"
    when "11010110" then new_char = "Ö"
    when "11011000" then new_char = "Ø"
    when "11011001" then new_char = "Ù"
    when "11011010" then new_char = "Ú"
    when "11011011" then new_char = "Û"
    when "11011100" then new_char = "Ü"
    when "11011101" then new_char = "Ý"
    when "11011110" then new_char = "Þ"
    when "11011111" then new_char = "ß"
    when "11100000" then new_char = "à"
    when "11100001" then new_char = "á"
    when "11100010" then new_char = "â"
    when "11100011" then new_char = "ã"
    when "11100100" then new_char = "ä"
    when "11100101" then new_char = "å"
    when "11100110" then new_char = "æ"
    when "11100111" then new_char = "ç"
    when "11101000" then new_char = "è"
    when "11101001" then new_char = "é"
    when "11101010" then new_char = "ê"
    when "11101011" then new_char = "ë"
    when "11101100" then new_char = "ì"
    when "11101101" then new_char = "í"
    when "11101110" then new_char = "î"
    when "11101111" then new_char = "ï"
    when "11110000" then new_char = "ð"
    when "11110001" then new_char = "ñ"
    when "11110010" then new_char = "ò"
    when "11110011" then new_char = "ó"
    when "11110100" then new_char = "ô"
    when "11110101" then new_char = "õ"
    when "11110110" then new_char = "ö"
    when "11110111" then new_char = "÷"
    when "11111000" then new_char = "ø"
    when "11111001" then new_char = "ù"
    when "11111010" then new_char = "ú"
    when "11111011" then new_char = "û"
    when "11111100" then new_char = "ü"
    when "11111101" then new_char = "ý"
    when "11111110" then new_char = "þ"
    when "11111111" then new_char = "ÿ"
    end
  
    return new_char
    
end

get ('/kryptera') do
    slim :kryptera
end

post ('/kryptera_post') do

    data = params[:secret_one]
    
    tvo = 5529600
    tre = 8294400
    fyra = 11059200
    fem = 13824000
    sex = 16588800

    tvoo = 884736
    tree = 1327104
    fyraa = 1769472
    femm = 2211840
    sexx = 2654208
    data = generate_random_characters(tvo)

    session[:session_meddelande] = data

    data = data + "|"

    pixel_array = array_name_pixels_from_image("./public/img/kryptera/#{session[:session_kryptera_img]}")

    pixel_array = to_binary(pixel_array)
    
    bred = pixel_array[0].length
    bred = ((bred) - 1)

    hog = pixel_array.length
    hog = ((hog) - 1)

    pixel_array = arne(pixel_array, data, bred, hog)

    pixel_array = to_rgb(pixel_array)

    from_pixels_to_image(pixel_array)

    redirect('/kryptera')

end

post ('/kryptera_img') do

    @data = params[:img_kryptera]
    session[:session_kryptera_img] = @data
    session[:session_kryptera_img_2] = @data[0...-4]
    
    redirect('/kryptera')

end

get ('/dekryptera') do
    slim :dekryptera
end

post ('/dekryptera_post') do

    password = "Amogus"
    session[:cor_password] = false 
    @data= params[:secret_two]
    session[:session_password] = @data

    if @data == password

        array = read_image("./public/img/dekryptera/#{session[:session_dekryptera_img]}")
      
        array = to_binary(array)

        bred = array[0].length
        bred = ((bred) - 1)
    
        hog = array.length
        hog = ((hog) - 1)

        system('cls')
        puts ""
        puts ""        
        puts hitta_meddelandet_from_binary_array(array,bred,hog)
        puts ""
        puts "" 

    else
        session[:cor_password] = true
        redirect('/dekryptera')
    end
    
    redirect('/dekryptera')

end

post ('/dekryptera_img') do

    @data = params[:img_dekryptera]
    session[:session_dekryptera_img] = @data

    redirect('/dekryptera')

end