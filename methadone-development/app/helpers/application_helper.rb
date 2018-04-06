module ApplicationHelper

  def bootstrap_class_for flash_type
    if ["error", "alert"].include? flash_type
      "alert-danger"
    else
      "alert-success"
    end
  end

end
