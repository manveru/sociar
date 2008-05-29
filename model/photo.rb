class Photo < Sequel::Model
  MODELS << self

  set_schema do
    primary_key :id

    varchar :caption, :size => 100
    varchar :image

    time :create_at
    time :updated_at

    foreign_key :profile_id
  end

  validations.clear
  validates_presence_of :image, :profile_id

  has_many :comments
  belongs_to :profile

  after_create do
    p :create => :FeedItem
    # feed_item = FeedItem.create(:item => self)
    # ([profile] + profile.friends + profile.followers).each{ |p| p.feed_items << feed_item }
  end

  # file_column :image, :magick => {
  #   :versions => {
  #     :square => {:crop => "1:1", :size => "50x50", :name => "square"},
  #     :small => "175x250>"
  #   }
  # }
end
