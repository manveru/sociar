SOCIAR = Configuration.for('sociar'){
  mode 'dev'

  site do
    title "Sociar"
    description "Sociar is an Open Source Social Network Platform"
    domain "sociar.com"
    keywords ['Open Source', 'Social Network', 'Ramaze']

    admin "manveru"
  end

  flickr do
    key 'f25defdbdb783cad6cabb25c3c8e1592'
    secret 'f34b7ef13f387da3'
    cache '.flickr_cache'
  end

  ramaze do
    host '0.0.0.0'
    port 7000
    adapter :thin
    boring [/\.css$/]
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
}
