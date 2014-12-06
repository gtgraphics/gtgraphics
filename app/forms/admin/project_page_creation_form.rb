class Admin::ProjectPageCreationForm < Admin::MultiplePageCreationForm
  include Tokenizable

  embeds_many :projects

  validates :project_ids, :project_id_tokens, presence: true

  tokenizes :project_ids

  def perform
    create_pages_for :projects
  end
end