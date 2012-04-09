module Her
  module Model
    # This module adds relationships to models
    module Relationships
      # Return relationships
      # @private
      def relationships # {{{
        @her_relationships
      end # }}}

      # Parse relationships data after initializing a new object
      # @private
      def parse_relationships(data) # {{{
        @her_relationships ||= {}
        @her_relationships.each_pair do |type, relationships|
          relationships.each do |relationship|
            data[relationship[:name]] = Her::Model::ORM.initialize_collection(relationship[:name], data[relationship[:name]]) if data.include?(relationship[:name])
          end
        end
        data
      end # }}}

      # Define an *has_many* relationship for the resource
      #
      # * `User.has_many :comments` is used to check if the "user" JSON
      #   resource we receive has a `comments` key and map it to an array
      #   of Comment.new objects
      # * `User.has_many :comments` creates a User.comments method to would
      #   make an extra HTTP request if there was no "comments" key
      def has_many(name, attrs={}) # {{{
        @her_relationships ||= {}
        (@her_relationships[:has_many] ||= []) << attrs.merge(:name => name)
        collection_path = @her_collection_path

        define_method(name) do
          return @data[name] if @data.include?(name) # Do not fetch from API again if we have it in @data
          self.class.get("#{collection_path}/#{id}/#{Object.const_get(name.to_s.classify).collection_path}") do |parsed_data|
            @data[name] = Her::Model::ORM.initialize_collection(name, parsed_data[:resource])
          end
        end
      end # }}}

      # Define a *belongs_to* relationship for the resource
      #
      # * `User.belongs_to :organzation` is used to check if the "user" JSON
      #   resource we receive has an `organzation` key and map it to
      #   an Organization.new object
      #
      # * `User.belongs_to :organzation` creates a User.organzation method
      def belongs_to(name, attrs={}) # {{{
        @her_relationships ||= {}
        (@her_relationships[:belongs_to] ||= []) << attrs.merge(:name => name)
      end # }}}
    end
  end
end
