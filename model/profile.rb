class Profile < Sequel::Model
  include Ramaze::Helper::CGI

  set_schema do
    primary_key :id

    text :about_me

    varchar :first_name
    varchar :last_name
    varchar :website
    varchar :blog
    varchar :flickr
    varchar :icon
    varchar :location

    varchar :aim_name
    varchar :flickr_name
    varchar :gtalk_name
    varchar :ichat_name
    varchar :youtube_name

    time :created_at
    time :updated_at

    varchar :email

    foreign_key :user_id
  end

  belongs_to :user
  has_many :blogs
  has_many :comments
  has_many :feeds
  has_many :photos

  # has_many :
  # has_many :feed_items,
  #          :through => :feeds,
  #          :order => 'created_at desc'
  # has_many :private_feed_items,
  #          :through => :feeds, :source => :feed_item,
  #          :conditions => {:is_public => false},
  #          :order => 'created_at desc'
  # has_many :public_feed_items,
  #          :through => :feeds,
  #          :source => :feed_item,
  #          :conditions => {:is_public => true},
  #          :order => 'created_at desc'

  before_create do
    self.created_at = Time.now
    self.updated_at = Time.now
  end

  before_save do
    self.updated_at = Time.now
  end

  def no_data?
    (created_at <=> updated_at) == 0
  end

  # Profile out

  def about_me_html
    Maruku.new(h(about_me)).to_html
  end

  # Links

  def website_link
    link = h(website)
    %|<a href="#{link}">#{link}</a>|
  end

  def blog_link
    %|Link to blog|
  end

  def aim_link
    name = h(aim_name)
    %|<a href="aim:goim?screenname=#{name}">#{name}</a>|
  end

  def gtalk_link
    name = h(gtalk_name)
    %|<a href="xmpp:#{name}">#{name}</a>|
  end

  def ichat_link
    name = h(ichat_name)
    %|<a href="ichat:#{name}">#{name}</a>|
  end

  def avatar(size = 'big')
    "/media/avatar/default_#{size}.png"
  end

  MODELS << self
end
