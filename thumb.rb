require 'image_science'

sizes = {
  'small' => 50,
  'medium' => 100,
  'big' => 150,
}

Dir['/home/manveru/files/photos/*'].each do |file|
  base = File.basename(file, File.extname(file))

  ImageScience.with_image(file) do |img|
    sizes.each do |name, size|
      img.cropped_thumbnail(size) do |thumb|
        out = "#{base}_#{name}.png"
        p out
        thumb.save(out)
      end
    end
  end
end
