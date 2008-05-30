class Comment < Sequel::Model
  MODELS << self

  set_schema do
    primary_key :id

    text :body

    time :created_at
    time :updated_at

    boolean :is_reviewed
    # integer :is_denied, :default => 0

    foreign_key :from_id
    foreign_key :to_id
  end

  many_to_one :from, :key => :from_id, :class => :User
  many_to_one :to, :key => :to_id, :class => :User

  validations.clear
  validates_presence_of :body, :from, :to

  before_create{ self.created_at = Time.now }
  before_save{ self.updated_at = Time.now }

  def self.latest(n = 10)
    order(:created_at.desc).limit(n).eager(:from)
  end

  def abstract(size = 50)
    if size and body.size > size
      body[0..size] + '...'
    else
      body
    end
  end
end

__END__
  after_create do
    feed_item = FeedItem.create(:item => self)

    p :create => :FeedItem
    # feed_item = FeedItem.create(:item => self)
    # ([profile] + profile.friends + profile.followers).each{ |p| p.feed_items << feed_item }
  end
end
