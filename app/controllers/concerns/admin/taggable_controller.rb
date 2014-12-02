module Admin::TaggableController
  extend ActiveSupport::Concern

  included do
    helper_method :taggable
  end

  def tag
    taggable.tag!(params.fetch(:tag))
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { redirect_via_turbolinks_to :back }
    end
  end

  def untag
    taggable.untag!(params.fetch(:tag))
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { redirect_via_turbolinks_to :back }
    end
  end


  # Tag Assignment

  def assign_tags
    @tag_assignment_activity = Admin::TagAssignmentActivity.new

    record_ids = Array(params[:"#{controller_name.singularize}_ids"])
    records = controller_name.classify.constantize.where(id: record_ids)

    @tag_assignment_activity.record_type = controller_name.classify
    @tag_assignment_activity.record_ids = record_ids
    @tag_assignment_activity.tag_list = Tag.common(records)

    respond_to do |format|
      format.js { render :assign_tags }
    end
  end

  def associate_tags
    @tag_assignment_activity = Admin::TagAssignmentActivity.execute(tag_assignment_params)

    respond_to do |format|
      format.js
    end
  end

  protected
  def taggable
    @taggable ||= controller_name.classify.constantize.find(params[:id])
  end

  def tag_assignment_params 
    params.require(:tag_assignment).permit(:tag_list, :record_type, record_ids: [])
  end
end