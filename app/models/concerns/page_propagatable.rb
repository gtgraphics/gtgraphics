module PagePropagatable
  extend ActiveSupport::Concern

  included do
    alias_method :propagate_changes_to_pages, :propagate_changes_to_pages?

    after_update :propagate_changes_to_pages!, if: :propagate_changes_to_pages?
  end

  def propagate_changes_to_pages?
    unless defined? @propagate_changes_to_pages
      @propagate_changes_to_pages = true
    end
    @propagate_changes_to_pages
  end

  def propagate_changes_to_pages=(propagate)
    @propagate_changes_to_pages = propagate.to_b
  end

  private

  def propagate_changes_to_pages!
    transaction do
      pages.each do |page|
        page.title = title
        page.meta_description = Rails::Html::FullSanitizer.new.sanitize(description)
        page.save!
      end
    end
  end
end
