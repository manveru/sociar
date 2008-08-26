#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'sequel'
require 'image_science'

# Scaffold image models utilizing thumbnailing and Ramaze integration.
# Resizing is done by ImageScience.
#
# Usage:
#   class Avatar < Sequel::Model
#     IMAGE = {
#       # specifies belongs_to, will create relation and foreign key
#
#       :owner => :User,
#
#
#       # Remove original and thumbnails on Avatar#destroy
#
#       :cleanup => true,
#
#
#       # Algorithm to use in ImageScience
#       #
#       # * resize(width, height)
#       #     Resizes the image to +width+ and +height+ using a cubic-bspline
#       #     filter.
#       #
#       # * thumbnail(size)
#       #     Creates a proportional thumbnail of the image scaled so its
#       #     longest edge is resized to +size+.
#       #
#       # * cropped_thumbnail(size)
#       #     Creates a square thumbnail of the image cropping the longest edge
#       #     to match the shortest edge, resizes to +size+.
#
#       :agorithm => :thumbnail,
#
#
#       # Key specifies the filename and accessors, value are arguments to the
#       # algorithm
#
#       :sizes => {
#         :small => 150,
#         :medium => 300,
#         :large => 600
#       }
#     }
#
#     # Perform the scaffold
#     include SequelImage
#   end

module Sequel
  module Plugins
    module Image
      def self.apply(model, options = {})
        model.before_create :image_generate_thumbnails do
          sizes, algorithm = image_opts.values_at(:sizes, :algorithm)
          generate_thumbnails(algorithm, sizes)
        end

        model.before_create :image_set_created_at do
          self.created_at = Time.now
        end

        model.before_save :image_set_updated_at do
          self.updated_at = Time.now
        end

        model.before_destroy :image_cleanup do
          cleanup if image_opts[:cleanup]
        end

        options[:sizes].each do |size, *args|
          model.send(:define_method, size){ public_file(size) }
          model.send(:define_method, "#{size}_url"){ file(size) }
        end
      end

      module ClassMethods
        def store_image(file, hash = {})
          image = new(hash)

          type, filename, tempfile =
            file.values_at(:type, :filename, :tempfile)

          size = tempfile.stat.size

          raise ArgumentError, 'Empty tempfile' if size == 0

          ext         = Ramaze::Tool::MIME.ext_for(type)
          image.mime  = type
          target_name = image.next_name(filename, ext)
          target_path = File.join(image.public_root, image.path, target_name)

          FileUtils.mkdir_p(File.dirname(target_path))
          FileUtils.cp(tempfile.path, target_path)

          image.original = target_path
          image.save
        end
      end

      module InstanceMethods
        include Ramaze::Helper::CGI, Ramaze::Helper::Link

        def file(size = nil)
          File.join('/', path, filename(size))
        end

        def original_file
          File.join('/', path, File.basename(original))
        end

        def public_file(size = nil)
          File.join(public_path, filename(size))
        end

        def public_path
          File.join(public_root, path)
        end

        def path
          image_opts[:path] || image_opts[:owner].to_s.downcase
        end

        def next_name(filename, ext)
          uid = File.basename(filename, File.extname(filename))
          uid = uid.to_s.scan(%r![^\\/'".:?&;\s]+!).join('-')
          "#{uid}#{ext}"
        end

        def basename
          File.basename(original, File.extname(original))
        end

        def public_root
          Ramaze::Global.public_root
        end

        def filename(size)
          if size
            "#{basename}_#{size}.png"
          else
            "#{basename}.png"
          end
        end

        def cleanup
          image_opts[:sizes].each do |name, args|
            out = public_file(name)
            Ramaze::Log.debug "Remove Thumbnail: #{out}"
            FileUtils.rm_f(out)
          end

          Ramaze::Log.debug "Remove original: #{original}"
          FileUtils.rm_f(original)
        end

        def generate_thumbnails(algorithm, sizes)
          FileUtils.mkdir_p(public_path)

          ImageScience.with_image(original) do |img|
            Ramaze::Log.debug "Process original: #{original}"

            sizes.each do |name, args|
              out = public_file(name)
              Ramaze::Log.debug "Generate Thumbnail: #{out}"

              img.send(algorithm, *args) do |thumb|
                thumb.save(out)
              end
            end
          end
        end
      end
    end
  end
end
