module ImagesHelper
  def plane_category_logo_name(plane_category)
    if plane_category.vietnam_airlines?
      return "vna.png"
    elsif plane_category.jetstar?
      return "jet.png"
    elsif plane_category.vietjet_air?
      return "vjet.png"
    else
      return ""
    end
  end

  def random_place_img
    rand(1..10)
  end
end
