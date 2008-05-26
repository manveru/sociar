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

  validates_presence_of :comment, :profile

  has_many :comments
  belongs_to :profile

  after_create do
    p :create => :FeedItem
    # feed_item = FeedItem.create(:item => self)
    # ([profile] + profile.friends + profile.followers).each{ |p| p.feed_items << feed_item }
  end
end
