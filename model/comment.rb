class Comment < Sequel::Model
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

  create_table unless table_exists?

  many_to_one :from, :key => :from_id, :class => :Profile
  many_to_one :to, :key => :to_id, :class => :Profile

  validations.clear
  validates_presence_of :body, :from, :to

  before_create(:time){ self.updated_at = self.created_at = Time.now }
  before_save(:time){ self.updated_at = Time.now }

  def self.latest(n = 10)
    order(:created_at.desc).eager(:from).limit(n)
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
