require 'ramaze/helper/gravatar'

class Profile < Sequel::Model
  include Ramaze::Helper::Link
  include Ramaze::Helper::CGI
  include Ramaze::Helper::Gravatar

  SEARCH = %w[
    login name location blog website flickr aim_name
    flickr_name gtalk_name ichat_name youtube_name
  ]

  set_schema do
    primary_key :id

    varchar :login # boost performance

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

  create_table unless table_exists?

  # Validation
  validations.clear
  validates do
    uniqueness_of :login, :email

    format_of :login, :with => /\A[\w.]+\z/
    length_of :login, :within => 3..255

    format_of :email, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    length_of :email, :within => 3..255
  end

  before_create(:time){ self.updated_at = self.created_at = Time.now }
  before_save(:time){ self.updated_at = Time.now }

  def self.search(query = {})
    return [] if query.empty?

    ds = order(:name, :login)

    (query.keys & SEARCH).each do |key|
      sql = ["#{key} LIKE '%' || ? || '%'", query[key]]

      if ds.sql =~ /WHERE/
        ds = ds.or(sql)
      else
        ds = ds.where(sql)
      end
    end

    ds
  end

  def self.latest(n = 10)
    order(:created_at.desc).limit(n)
  end

  # Check things to do

  def profile_empty?
    (created_at <=> updated_at) == 0
  end

  def images_empty?
    images.empty?
  end

  def messages_empty?
    sent_messages.empty?
  end

  def blog_empty?
    blogs.empty?
  end

  # TODO
  def friends_empty?
    return true
    @profile.followings.empty? and @profile.friends.empty?
  end

  # Profile out

  def name
    self[:name] || login
  end

  def avatar(size = 50)
    s = { 50 => 'small', 100 => 'medium', 150 => 'big' }[size]

    if Ramaze::Global.mode == 'live'
      gravatar(email, size, "/media/avatar/default_#{s}.png")
    else
      "/media/avatar/default_#{s}.png"
    end
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

  def received_comments(n = 10)
    Comment.filter(:to_id => id).order(:created_at.desc).limit(n)
  end

  def received_messages(n = 10)
    Message.filter(:to_id => id).order(:created_at.desc).limit(n)
  end

  def sent_messages(n = 10)
    Message.filter(:from_id => id).order(:created_at.desc).limit(n)
  end

  # Autocomplete

  def self.autocomplete(query)
    return [] unless query

    sql = ["login LIKE '%' || ? || '%'", query]
    order(:login).where(sql).map{|profile| profile.login}
  end

  # Quick profile access

  def to_url
    R(ProfileController, h(login))
  end

  def location_url
    R(ProfileController, :search, :location => location)
  end

  def avatar_linked_image(size = 50)
    %|<a href="#{to_url}"><img src="#{avatar(size)}" alt="Avatar" /></a>|
  end

  def name_linked
    %|<a href="#{to_url}" class="name">#{h name}</a>|
  end

  def location_linked
    %|<a href="#{location_url}" class="location">#{h location}</a>|
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
      href = to_url
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
end
