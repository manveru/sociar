class Blog < Sequel::Model
  include Ramaze::Helper::Link
  include Ramaze::Helper::CGI

  set_schema do
    primary_key :id

    varchar :title
    text :body

    time :created_at
    time :updated_at

    foreign_key :profile_id
  end

  create_table unless table_exists?

  belongs_to :profile
  has_many :comments

  validations.clear
  validates do
    presence_of :title, :body, :profile_id
    format_of :title, :with => /\A.*\S+.*\Z/, :message => 'is empty'
    format_of :body, :with => /\A.*\S+.*\Z/, :message => 'is empty'
  end

  hooks.clear
  before_create{ self.created_at = Time.now }
  before_save{ self.updated_at = Time.now }
  after_create do
    # feed_item = FeedItem.create(:item => self)
    # affected_profiles.each do |pr|
    #   pr.feed_items << feed_item
    # end
  end

  def user
    profile.user
  end

  def to_url
    "#{profile.user.login}/#{id}-#{linkable_title}"
  end

  def linkable_title
    title.gsub(/\W+/, '-').downcase
  end

  def title_linked
    A h(title), :href => R(BlogController, to_url)
  end

  def abstract(size = 50)
    if size and body.size > size
      b = body[0..size] + '...'
    else
      b = body
    end

    h(b).gsub("\n", "<br />")
  end

  def affected_profiles
    [profile] + profile.friends + profile.followers
  end
end
