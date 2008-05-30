class User < Sequel::Model
  set_schema do
    primary_key :id

    varchar :login, :size => 255, :unique => true
    varchar :openid, :unique => true
    varchar :crypted_password, :size => 40
    varchar :salt, :size => 40

    varchar :timezone, :size => 3, :default => 'UTC'

    time :created_at
    time :updated_at

    varchar :remember_token, :size => 255
    time    :remember_token_expires_at

    boolean :active,            :default => true
    boolean :is_admin,          :default => false
    boolean :can_send_messages, :default => false

    varchar :email_verification, :size => 255
    boolean :email_verified

    foreign_key :profile_id
  end

  belongs_to :profile

  # Validation
  attr_accessor :password, :password_confirmation, :email

  validations.clear
  validates_uniqueness_of :login
  validates_confirmation_of :password
  validates_length_of :password, :within => 6..255
  validates_length_of :login, :within => 3..255

  before_create{ self.created_at = Time.now }
  before_save{ self.updated_at = Time.now }

  # Remember until next year
  def remember_me
    self.remember_token_expires_at = Time.now.utc + (1 * 365 * 24 * 60 * 60)
    self.remember_token ||= "#{uuid}-#{uuid}"
    save
  end

  def post_create
    self.crypted_password = encrypt(password)
    self.profile = profile = Profile.create(:email => email)
    save
  end

  def can_mail?(user)
    can_send_messages && active
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def self.prepare(hash)
    user = new(hash)
    user.email = hash['email']
    user.password = hash['password']
    user.password_confirmation = hash['password_confirmation']
    user.salt = Digest::SHA1.hexdigest("--#{Time.now.to_f}--#{user.login}--")
    user
  end

  def self.authenticate(hash)
    login, pass = hash['login'], hash['password']

    if user = User[:login => login]
      return user unless pass # we don't store the password in the session...
      user if user.authenticated?(pass)
    end
  end

  def self.latest(n = 10)
    order(:created_at.desc).limit(n).eager(:profile)
  end

  # Quick profile access
  include Ramaze::Helper::Link
  include Ramaze::Helper::CGI

  def profile_url
    R(ProfileController, :show, h(login))
  end
  alias to_url profile_url

  def location_url
    R(ProfileController, :search, h(location))
  end

  def avatar(size)
    profile.avatar(size)
  end

  def avatar_linked_image(size = 50)
    %|<a href="#{profile_url}"><img src="#{avatar(size)}"alt="Avatar" /></a>|
  end

  def name_linked
    %|<a href="#{profile_url}" class="name">#{h profile.name}</a>|
  end

  def location_linked
    %|<a href="#{location_url}" class="location">#{h profile.location}</a>|
  end

  def location
    profile.location
  end

  private

  # FIXME: install uuid lib?
  def uuid
    return rand(1e128)
    UUID.random_create
  end

  MODELS << self
end
