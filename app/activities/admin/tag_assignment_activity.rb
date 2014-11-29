class Admin::TagAssignmentActivity < Activity
  attribute :record_type, String
  attribute :record_ids, Array[Integer]
  attribute :tag_list, TagCollection, coercer: ->(list) { TagCollection.parse(list) }

  def perform
    records = record_type.constantize.where(id: record_ids)
    Tag.transaction do
      records.each do |record|
        record.untag(tag_list.to_a - record.tag_list.to_a)
        record.tag(tag_list.to_a)
        record.save!
      end
    end
  end
end
