module Breadcrumb
  class Item
    extend ActiveModel::Naming

    attr_reader :collection, :caption, :destination, :path, :url
    private :collection

    def initialize(collection, caption, destination = nil)
      unless collection.is_a? Breadcrumb::Collection
        fail ArgumentError, 'no breadcrumb collection specified'
      end

      @collection = collection
      @caption = caption
      @destination = destination

      return if @destination.nil?
      if @destination.is_a? String
        @path = @url = @destination
      else
        @path = collection.controller.url_for(destination)
        @url = collection.controller.url_for(destination)
      end
    end

    def index
      collection.index(self)
    end

    def first?
      index.zero?
    end

    def last?
      index == collection.length - 1
    end

    def inspect
      "#<#{self.class.name} caption: #{caption.inspect}, " \
        "destination: #{destination.inspect}>"
    end

    def to_s
      caption
    end
  end
end
