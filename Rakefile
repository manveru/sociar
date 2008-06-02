require 'rake'

task :default => :spec

task :spec do
  Dir['spec/story/**/*.rb'].each do |spec|
    ruby spec
  end
end

desc 'Thumnails regeneration'
task 'thumb:regenerate' => ['thumb:clean', 'thumb:generate']

desc 'Thumnails clean'
task 'thumb:clean' do
  Dir['public/image/*.{jpg,png,gif}'].each do |img|
    base = File.basename(img)

    if base =~ /^.+_\d+_(\w+)\....$/
      FileUtils.rm(img)
    end
  end
end

desc 'Thumnails generation'
task 'thumb:generate' do
  require 'ramaze'
  require 'sequel'
  db = Sequel.sqlite
  require 'model/image'
  require 'vendor/image_science_cropped_resize'

  Dir['public/image/*.{png,jpg,gif}'].each do |img|
    Image.new(:original => img).send(:generate_thumbnails, Image::SIZES)
  end
end
