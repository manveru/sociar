require 'ramaze/gestalt'

module Ramaze
  module Helper
    module Form

      def form_text(label, name, value = nil)
        input label, :type => :text, :name => name, :value => value
      end

      def form_checkbox(label, name, checked = false)
        if checked
          input label, :type => :checkbox, :name => name, :checked => :checked
        else
          input label, :type => :checkbox, :name => name
        end
      end

      def form_password(label, name)
        input label, :type => :password, :name => name
      end

      def form_textarea(label, name, value = nil)
        form_build(:textarea, label, :name => name){ value }
      end

      def input(label, hash)
        form_build(:input, label, hash)
      end

      def form_file(label, name)
        input label, :type => :file, :name => name
      end

      def form_build(tag_name, label, hash, &block)
        form_id = "form-#{hash[:name]}"

        Ramaze::Gestalt.build{
          label(:for => form_id){ "#{label}:" }
          tag(tag_name, hash.merge(:id => form_id), &block)
          div(:class => "clearfix"){ "" }
        }
      end

    end
  end
end
