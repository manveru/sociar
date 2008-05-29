class Profile < Sequel::Model
  MODELS << self

  include Ramaze::Helper::CGI

  set_schema do
    primary_key :id

    text :about_me

    varchar :name
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

  def avatar(size = 'big')
    "/media/avatar/default_#{size}.png"
  end

  # sizes are
  # Square Thumbnail Small Medium Large
  def flickr_photos(size = 'Thumbnail')
    if flickr_name
      if user = FLICKR.users(flickr_name)
        return user.photos.each{|photo|
          yield(photo.source(size))
        }
      end
    end

    []
  rescue
    []
  end

  def blog_posts(n = 10)
    Blog.filter(:profile_id => self.id).order(:created_at).limit(n)
  end

  # Links

  def website_link
    flink website
  end

  def blog_link
    flink blog
  end

  def flickr_link
    flink flickr
  end

  def aim_link
    flink aim_name, '<a href="aim:goim?screenname=%value">%value</a>'
  end

  def gtalk_link
    flink gtalk_name, '<a href="xmpp:%value">%value</a>'
  end

  def ichat_link
    flink ichat_name, '<a href="ichat:%value">%value</a>'
  end

  private

  def flink(value, url = '<a href="%value">%value</a>')
    return unless value
    esc = h(value)
    url.gsub('%value', esc)
  end
end
