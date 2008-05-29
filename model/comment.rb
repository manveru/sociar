class Comment < Sequel::Model
  MODELS << self

  set_schema do
    primary_key :id

    text :comment

    time :created_at
    time :updated_at

    foreign_key :profile_id

    boolean :is_reviewed

    # integer :is_denied, :default => 0
  end

  validations.clear
  validates_presence_of :comment, :profile

  has_many :comments
  belongs_to :profile

  before_create{ self.created_at = Time.now }
  before_save{ self.updated_at = Time.now }

  after_create do
    feed_item = FeedItem.create(:item => self)

    p :create => :FeedItem
    # feed_item = FeedItem.create(:item => self)
    # ([profile] + profile.friends + profile.followers).each{ |p| p.feed_items << feed_item }
  end

  def self.latest(n = 10)
    order(:created_at.desc).limit(n).eager(:profile)
  end
end
