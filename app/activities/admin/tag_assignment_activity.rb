class Admin::TagAssignmentActivity < Activity
  attribute :record_type, String
  attribute :record_ids, Array[Integer]
  attribute :tag_list, TagCollection, coercer: ->(list) { TagCollection.parse(list) }

  def perform
    records = record_type.constantize.where(id: record_ids)

    common_tags = Tag.common(records).map(&:label)

    Tag.transaction do
      records.each do |record|
        persisted_tags = record.tag_list.to_a
        added_tags = tag_list.to_a - persisted_tags
        
        # only common tags can be removed
        removed_tags = (persisted_tags - tag_list.to_a) & common_tags

        record.tag_list.add(added_tags)
        record.tag_list.remove(removed_tags)
        record.save!
      end
    end
  end
end
