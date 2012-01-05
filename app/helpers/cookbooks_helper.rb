module CookbooksHelper

  def visible?(recipe)
    cookbook_name, recipe_name = recipe.split("::")
    return "hidden" if Cookbook::HIDDEN.include?(cookbook_name)
  end

end
