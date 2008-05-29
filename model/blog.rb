class Blog < Sequel::Model
  set_schema do
    primary_key :id

    varchar :title
    text :body

    time :created_at
    time :updated_at

    foreign_key :profile_id
  end

  validations.clear
  validates_presence_of :title, :body, :profile_id

  belongs_to :profile
  has_many :comments

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
    "#{user.login}/#{id}-#{linkable_title}"
  end

  def linkable_title
    title.gsub(/\W+/, '-').downcase
  end

  def affected_profiles
    [profile] + profile.friends + profile.followers
  end


  MODELS << self
end
