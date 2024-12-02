require 'sinatra' # Web application framework
require 'sinatra/reloader' # Allows automatic reloading during development
require 'slim' # Lightweight templating engine
require 'rubygems' # Manages RubyGems dependencies
require 'rmagick' # Library for image manipulation
enable :sessions # Enables session management for storing user data

# Converts a 2D array of pixels (RGB values) into an image and saves it as a file
def from_pixels_to_image(pixels)
  # Validate input: pixels must be a 2D array with each element being an array of [R, G, B]
  unless pixels.is_a?(Array) && pixels.all? { |row| row.is_a?(Array) && row.all? { |p| p.is_a?(Array) && p.size == 3 } }
    raise "Invalid pixel data format"
  end

  # Determine image dimensions
  height = pixels.length
  width = pixels[0].length

  # Create a new blank image with the specified dimensions
  image = Magick::Image.new(width, height)

  # Flatten 2D pixel array into a 1D array of Magick::Pixel objects
  pixel_array = []
  pixels.each do |row|
    row.each do |pixel|
      r, g, b = pixel
      # Convert 8-bit RGB values (0–255) to 16-bit (0–65535)
      pixel_array << Magick::Pixel.new(r * 257, g * 257, b * 257)
    end
  end

  # Validate that the total number of pixels matches the image dimensions
  raise "Pixel-arrayens storlek matchar inte bildens dimensioner!" if pixel_array.size != width * height

  # Apply the pixel data to the image
  image.store_pixels(0, 0, width, height, pixel_array)

  # Debug: Log pixel data if debugging is enabled
  if ENV['DEBUG']
    exported_pixels = image.export_pixels(0, 0, width, height, "RGB")
    puts "Exported pixels: #{exported_pixels.map { |v| v / 257 }.each_slice(3).to_a.inspect}"
  end

  # Save the image to a file in the specified directory
  output_dir = "/path/to/public/img/kryptera"
  FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir) # Ensure the directory exists
  output_file = "#{output_dir}/output_#{session[:session_kryptera_img] || 'default'}.jpg"
  image.write(output_file)
  puts "Bilden har sparats som '#{output_file}'."
end

# Reads an image and returns its pixel data as a 2D array of RGB values
def array_name_pixels_from_image(image_path)
  image = Magick::Image.read(image_path).first # Load the image

  # Create a 2D array to store pixel RGB values
  rgb_values = []
  image.rows.times do |y|
    row = []
    image.columns.times do |x|
      pixel = image.pixel_color(x, y)
      # Convert 16-bit RGB values to 8-bit and store them
      r = (pixel.red / 257).to_i
      g = (pixel.green / 257).to_i
      b = (pixel.blue / 257).to_i
      row << [r, g, b]
    end
    rgb_values << row
  end

  # Return the array of RGB values
  rgb_values
end

# Converts binary pixel values to RGB (decimal) format
def to_rgb(pixels)
  pixels.map do |row|
    row.map do |(r_bin, g_bin, b_bin)|
      [r_bin.to_i(2), g_bin.to_i(2), b_bin.to_i(2)] # Convert binary to integer
    end
  end
end

# Converts RGB pixel values to binary format
def to_binary(pixels)
  pixels.map do |row|
    row.map do |(r, g, b)|
      [
        r.to_s(2).rjust(8, '0'), # Convert to binary and pad to 8 bits
        g.to_s(2).rjust(8, '0'),
        b.to_s(2).rjust(8, '0')
      ]
    end
  end
end

# Converts a single character to its ASCII binary representation
def ascii(element)
  # Map the character to its binary ASCII value
  case element
  when "a".."z" then element.ord.to_s(2).rjust(8, '0') # Automatically handles lowercase a-z
  else
    raise "kan inte skriva #{element}" # Raise an error for unsupported characters
  end
end

# Displays the form for encryption
get('/kryptera') do
  slim :kryptera
end

# Handles form submission for encryption
post('/kryptera_post') do
  # Array to store binary representation of input text
  array_of_binary_from_text = []
  data = params[:secret_one] # Retrieve user input
  session[:session_meddelande] = data # Store input in session

  # Load the selected image and convert it to a binary pixel array
  pixel_array = array_name_pixels_from_image("/public/img/kryptera/#{session[:session_kryptera_img]}")
  pixel_array = to_binary(pixel_array)

  # Convert the input text to binary and store in array
  data.each_char { |char| array_of_binary_from_text << ascii(char) }

  # Embed binary data into the least significant bits of the image's pixel data
  i, z, b = 0, 0, 0
  bob = false
  while i < array_of_binary_from_text.length
    if [8, 5, 2].include?(array_of_binary_from_text[i].length)
      if bob
        z += 1
        b = 0
      end
      bob = true
    end

    # Modify the pixel's least significant bit with binary data
    pixel_array[0][z][b][7] = array_of_binary_from_text[i][0]
    array_of_binary_from_text[i].slice!(0)
    i += 1 if array_of_binary_from_text[i].empty?
    b += 1
  end

  # Convert the binary pixel array back to RGB format and save the image
  pixel_arrayo = to_rgb(pixel_array)
  from_pixels_to_image(pixel_arrayo)

  redirect('/kryptera') # Redirect to the encryption page
end

# Sets the image to be used for encryption
post('/kryptera_img') do
  session[:session_kryptera_img] = params[:img_kryptera] # Store image name in session
  redirect('/kryptera')
end

# Displays the form for decryption
get('/dekryptera') do
  slim :dekryptera
end

# Handles form submission for decryption (logic not provided)
post('/dekryptera_post') do
  session[:session_password] = params[:secret_two] # Store input in session
  redirect('/dekryptera')
end

# Sets the image to be used for decryption
post('/dekryptera_img') do
  session[:session_dekryptera_img] = params[:img_dekryptera] # Store image name in session
  redirect('/dekryptera')
end
