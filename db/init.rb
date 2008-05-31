unless defined?(DB)
  require 'sequel'
  require 'ramaze'
  DB = Sequel.sqlite
  MODELS = []
  require 'model/user'
  require 'model/profile'
  require 'model/blog'
  MODELS.each{|m| m.create_table }
end

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
    user.post_create

    pr = user.profile
    pr.user = user

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

    blog = Blog.new(:profile => pr)
    blog.title = Faker::Company.bs
    blog.body = Faker::Lorem.paragraphs(rand(5) + 1).join("\n")
    blog.save
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
    user.post_create
    profile = user.profile

    y.each do |key, value|
      profile.send("#{key}=", value)
    end

    profile.user = user
    profile.save

    blog = Blog.new(:profile => profile)
    blog.title = 'Welcome to Sociar'
    blog.body = 'Well, here it is. Sociar is now yours!'
    blog.save
  end
end

User.each do |from|
  User.each do |to|
    next if from.id == to.id
    next if rand > 0.42

    body = Faker::Lorem.paragraph
    Comment.create(:body => body, :from => from, :to => to)
  end
end
