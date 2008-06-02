require 'ramaze/helper/gravatar'

class Profile < Sequel::Model
  MODELS << self

  include Ramaze::Helper::CGI
  include Ramaze::Helper::Gravatar

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
  has_many :images

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

  # Hooks
  hooks.clear

  before_create do
    self.created_at = Time.now
    self.updated_at = Time.now
  end

  before_save do
    self.updated_at = Time.now
  end

  SEARCH = %w[name location blog website flickr aim_name flickr_name gtalk_name
    ichat_name youtube_name]

  def self.search(query = {})
    SEARCH.map{|key|
      key, value = key.to_sym, query[key]
      self.filter(key => value).all if value
    }.flatten.compact.uniq.map{|profile| profile.user }
  end

  def no_data?
    (created_at <=> updated_at) == 0
  end

  # Profile out

  def name
    self[:name] || user.login
  end

  def avatar(size = 50)
    s = { 50 => 'small', 100 => 'medium', 150 => 'big' }[size]
    gravatar(email, size, "/media/avatar/default_#{s}.png")
  rescue => ex
    Ramaze::Log.error(ex)
    "/media/avatar/default_#{s}.png"
  end

  # sizes are:
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

  def link_for(sym)
    value = self[sym]
    return if value.to_s.strip.empty?
    value = h(value)

    case sym
    when :aim_name
      title = "AIM"
      href = "aim:goim?screenname=#{value}"
    when :gtalk_name
      title ="GTalk"
      href = "xmpp:#{value}"
    when :ichat_name
      title = "iChat"
      href = "ichat:#{value}"
    when :flickr_name
      title = "Flickr"
    when :youtube_name
      title = "Youtube"
    when :name
      href = user.profile_url
    end

    title ||= sym.to_s.capitalize
    href ||= value
    [title, %|<a href="#{href}">#{value}</a>|]
  end


  PUBLIC_INFO = [
    :name, :website, :blog, :flickr, :icon, :aim_name, :flickr_name,
    :gtalk_name, :ichat_name, :youtube_name
  ]

  def render_info
    PUBLIC_INFO.map{|sym| render_tr(sym) }.compact.join("\n")
  end

  def render_tr(sym)
    title, value = link_for(sym)
    if title and value
      %|<tr><td class="key">#{title}:</td><td class="value">#{value}</td></tr>|
    end
  end

  private

  def flink(value, url = '<a href="%value">%value</a>')
    return unless value
    esc = h(value)
    url.gsub('%value', esc)
  end
end
