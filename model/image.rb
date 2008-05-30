class Image < Sequel::Model
  MODELS << self

  PATH = "/image"

  set_schema do
    primary_key :id

    varchar :caption, :size => 100
    varchar :original

    time :created_at
    time :updated_at

    foreign_key :profile_id
  end

  belongs_to :profile

  def public_file(size)
    File.join(public_path, "#{basename}_#{size}.png")
  end

  def public_path
    File.join(public_root, PATH)
  end

  def small;  public_file(:small); end
  def medium; public_file(:medium); end
  def large;  public_file(:large); end

  def small_url; file(:small); end
  def medium_url; file(:medium); end
  def large_url; file(:large); end

  before_create do
    self.created_at = Time.now
  end

  before_save do
    generate_thumbnails(:small => 50, :medium => 100, :large => 150)
    self.updated_at = Time.now
  end

  def self.latest(n = 10)
    order(:created_at.desc).limit(n).eager(:profile)
  end

  private

  def basename
    File.basename(original, File.extname(original))
  end

  def public_root
    if defined?(Ramaze)
      Ramaze::Global.public_root
    else
      './'
    end
  end

  def generate_thumbnails(sizes = {})
    require 'image_science'
    FileUtils.mkdir_p(public_path)

    ImageScience.with_image(original) do |img|
      puts "Generate Thumbnails for: #{original}"

      sizes.each do |name, size|
        img.thumbnail(size) do |thumb|
          out = public_file(name)
          thumb.save(out)
        end
      end
    end
  end
end
