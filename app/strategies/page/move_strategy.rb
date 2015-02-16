class Page::MoveStrategy
  attr_reader :source_page, :destination_page, :position

  POSITIONS = %w(inside before after).freeze

  class MoveError < StandardError
    attr_reader :strategy
    delegate :source_page, :destination_page, :position, to: :strategy

    def initialize(strategy)
      @strategy = strategy
    end
  end

  class InvalidDestinationError < MoveError; end
  class InvalidPositionError < MoveError; end

  def initialize(source, destination, position)
    @source_page = source
    @destination_page = destination
    @position = position.to_s
    @original_parent_id = @source_page.parent_id
  end

  def self.move(*args, &block)
    new(*args, &block).move
  end

  def self.move!(*args, &block)
    new(*args, &block).move!
  end

  def move
    move!
  rescue MoveError
    false
  end

  def move!
    verify_movability!
    Page.transaction do
      send("move_#{position}")
      source_page.refresh_path!(true)
      update_counter_caches
    end
    true
  end

  private

  def move_inside
    slug = next_available_slug(source_page.slug, destination_page.id)
    source_page.update_column(:slug, slug)
    source_page.move_to_child_with_index(destination_page, 0)
  end

  def move_before
    slug = next_available_slug(source_page.slug, destination_page.parent_id)
    source_page.update_column(:slug, slug)
    source_page.move_to_left_of(destination_page)
  end

  def move_after
    slug = next_available_slug(source_page.slug, destination_page.parent_id)
    source_page.update_column(:slug, slug)
    source_page.move_to_right_of(destination_page)
  end

  def next_available_slug(slug, parent_id)
    while Page.without(source_page).exists?(slug: slug, parent_id: parent_id)
      slug = slug.next
    end
    slug
  end

  def update_counter_caches
    page_ids = [source_page.id, source_page.parent_id, @original_parent_id,
                destination_page.id, destination_page.parent_id].compact.uniq
    page_ids.each do |page_id|
      Page.reset_counters(page_id, :children)
    end
  end

  def verify_movability!
    if source_page == destination_page
      fail InvalidDestinationError.new(self),
           'Source and destination page may not be the same'
    end
    return if position.in?(POSITIONS)
    fail InvalidPositionError.new(self), "Invalid position: #{position}"
  end
end
