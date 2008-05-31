class Image < Sequel::Model
  MODELS << self

  PATH = "/image"
  SIZES = {
    :small => 50, :medium => 100, :large => 150
  }

  set_schema do
    primary_key :id

    varchar :caption, :size => 100
    varchar :original

    time :created_at
    time :updated_at

    foreign_key :profile_id
  end

  belongs_to :profile

  # Hooks
  hooks.clear

  before_create do
    self.created_at = Time.now
  end

  before_save do
    generate_thumbnails(SIZES)
    self.updated_at = Time.now
  end


  def file(size)
    File.join(PATH, filename(size))
  end

  def public_file(size)
    File.join(public_path, filename(size))
  end

  def public_path
    File.join(public_root, PATH)
  end

  def filename(size)
    if size
      "#{basename}_#{size}.png"
    else
      "#{basename}.png"
    end
  end

  def small;  public_file(:small); end
  def medium; public_file(:medium); end
  def large;  public_file(:large); end

  def small_url; file(:small); end
  def medium_url; file(:medium); end
  def large_url; file(:large); end

  def self.latest(n = 10)
    order(:created_at.desc).limit(n).eager(:profile)
  end

  def self.store(profile, request)
    image = new(:profile => profile, :caption => request[:caption])

    file = request[:image]

    type     = file[:type]
    filename = file[:filename]
    tempfile = file[:tempfile]

    ext = ext_for(type, filename)
    target_name = image.next_name(ext)
    target_path = File.join(Ramaze::Global.public_root, PATH, target_name)

    FileUtils.mkdir_p(File.dirname(target_path))
    FileUtils.cp(tempfile.path, target_path)
    image.original = target_path
    image.save
    profile.add_image(image)
    profile.save
  end

  def self.ext_for(mime, name)
    case mime
    when /png/
      '.png'
    when /jpg/
      '.jpg'
    when /gif/
      '.gif'
    else
      ext = File.extname(name.to_s)
      ext.empty? ? '.png' : ext
    end
  end

  def next_name(ext)
    n = self.class.filter(:profile_id => profile.id).count + 1
    "%s_%08d%s" % [profile.user.login, n, ext]
  end

  include Ramaze::Helper::CGI
  include Ramaze::Helper::Link

  # TODO: lightbox
  def linked(size)
    src = send("#{size}_url")
    %|<a href="#{file}"><img src="#{src}"alt="#{h caption}" /></a>|
  end

  def delete_link
    href = R(ImageController, :delete, id)
    %|<a href="#{href}" class="location">Delete</a>|
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
        out = public_file(name)
        next if File.file?(out)

        img.thumbnail(size) do |thumb|
          thumb.save(out)
        end
      end
    end
  end
end