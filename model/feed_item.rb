class FeedItem < Sequel::Model
  set_schema do
    primary_key :id

    boolean :include_comments
    boolean :is_public

    time :created_at
    time :updated_at

    foreign_key :item_id
  end

  create_table unless table_exists?
end

__END__
# == Schema Information
# Schema version: 1
#
# Table name: feed_items
#
#  id               :integer(11)   not null, primary key
#  include_comments :boolean(1)    not null
#  is_public        :boolean(1)    not null
#  item_id          :integer(11)
#  item_type        :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class FeedItem < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  has_many :feeds

  def partial
    item.class.name.underscore
  end
end
