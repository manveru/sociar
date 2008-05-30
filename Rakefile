require 'rake'

task :default => :spec

task :spec do
  Dir['spec/story/**/*.rb'].each do |spec|
    ruby spec
  end
end
