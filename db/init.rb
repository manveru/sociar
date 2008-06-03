if User.count == 0
  require 'faker'

  5.times do
    name = Faker::Name.name
    login = Faker::Internet.user_name(name)
    email = Faker::Internet.free_email(login)
    password = "fake-#{login}"

    user = User.prepare('email' => email,
                        'password' => password,
                        'password_confirmation' => password,
                        'login' => login)

    user.save

    pr = user.profile

    pr.name = name
    pr.about_me = Faker::Company.bs

    pr.blog = "http://#{Faker::Internet.domain_name}"
    pr.website = "http://#{Faker::Internet.domain_name}"

    pr.location = Faker::Address.us_state

    pr.aim_name = Faker::Internet.user_name
    pr.flickr_name = Faker::Internet.user_name
    pr.gtalk_name = Faker::Internet.user_name
    pr.flickr = "http://flickr.com/photos/#{pr.flickr_name}"
    pr.save
  end

  # The time for custom profiles should be distinct so they are sorted before
  sleep 1

  YAML.load_file('db/init/user.yaml').each do |y|
    email = y.delete('email')
    password = y.delete('password')
    login = y.delete('login')
    user = User.prepare('email' => email,
                        'password' => password,
                        'password_confirmation' => password,
                        'login' => login)
    user.save
    profile = user.profile

    y.each do |key, value|
      profile.send("#{key}=", value)
    end

    profile.user = user
    profile.save
  end

  Profile.each do |from|
    Profile.each do |to|
      next if from.id == to.id
      next if rand > 0.42

      body = Faker::Lorem.paragraph
      Comment.create(:body => body, :from => from, :to => to)
    end

    blog = Blog.new(:profile => from)
    blog.title = Faker::Company.bs
    blog.body = Faker::Lorem.paragraphs(rand(5) + 1).join("\n")
    blog.save
  end

  admin = User[:login => SOCIAR.site.admin]
  admin.set :is_admin => true
  blog = Blog.new(:profile => admin.profile)
  blog.title = 'Welcome to Sociar'
  blog.body = 'Well, here it is. Sociar is now yours!'
  blog.save

  Dir['public/image/*.{png,jpg,gif}'].each do |img|
    if img =~ /([\w.]+)_(\d+)\.(.+)$/
      user = User[:login => $1] || admin
      profile = user.profile
      caption = Faker::Lorem.sentence

      image = Image.new(:profile => profile, :caption => caption, :original => img)

      profile.add_image(image)
      profile.save
    end
  end
end
