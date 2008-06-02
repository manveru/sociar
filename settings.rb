config_keys = [:title, :flickr, :description, :author, :keywords]
SOCIAR = Struct.new('SociarConfig', *config_keys).new
YAML.load_file('settings.yaml').each do |key, value|
  case key.to_s
  when /^flickr$/
    if file = File.expand_path(value.to_s)
      value = File.read(file).strip
    end
  end

  SOCIAR[key] = value
end
