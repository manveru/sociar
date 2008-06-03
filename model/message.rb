class Message < Sequel::Model
  set_schema do
    primary_key :id

    text :body
    varchar :subject

    time :created_at
    time :updated_at

    foreign_key :from_id
    foreign_key :to_id
  end

  create_table unless table_exists?

  many_to_one :from, :key => :from_id, :class => :Profile
  many_to_one :to, :key => :to_id, :class => :Profile

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
