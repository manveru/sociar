Configuration.for 'sociar' do
  mode 'dev'

  site do
    title "Sociar"
    description "Sociar is an Open Source Social Network Platform"
    domain "sociar.com"
    author "manveru"
    keywords ['Open Source', 'Social Network', 'Ramaze']
  end

  flickr do
    key File.read(File.expand_path('~/.flickr_api_key')).strip
    secret '643cbb44766793f1'
    cache '.flickr_cache'
  end

  ramaze do
    host '0.0.0.0'
    port 7000
    adapter :thin
  end

  sequel do
    logger nil
    # logger Logger.new($stdout)
  end

  mail do
    to "info@%domain"
    from "The Sociar Team <info@sociar.com>"
    registration_bcc = []
  end
end
