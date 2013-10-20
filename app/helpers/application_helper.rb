module ApplicationHelper
  def microtimestamp
    (Time.now.to_f * 1_000_000).to_i
  end
end
