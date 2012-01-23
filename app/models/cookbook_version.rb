class CookbookVersion < ChefBase

  def self.all
    Cookbook.all.map(&:versions)
  end

  def grouped_attributes(recipe = nil, filter = true)
    grouped = {}
    if !recipe.blank? and filter == true
      attributes = metadata["attributes"].delete_if{|x,y| !y["recipes"].include?(recipe)}
    else
      attributes = metadata["attributes"]
    end


    attributes.each_pair do |key,value|
      # cookbook, attribute, subattribute = key.split("/")
      cookbook, recipe = recipe.split("::")
      recipe, attribute, subattribute = key.split("/")

      grouped[recipe] = {} if grouped[recipe].blank?

      grouped[recipe][attribute] = {:principal => {}, :attributes => [], :recipe => recipe} if grouped[recipe][attribute].nil?
      if value["type"] =="array"
      #if !subattribute.blank?
        grouped[recipe][attribute][:principal] = {key, value}
      else
        grouped[recipe][attribute][:attributes]<< ({key, value})
      end
      order = !value["order"].nil? ? value["order"].to_i : 99
      grouped[recipe][attribute][:order] = order
    end
    grouped
  end


  def multiple_attributes(recipe)
    self.grouped_attributes(recipe).select{|x,y| !y[:principal].blank?}.map{|x| x[0]}
  end

  def initialize_attributes(recipe, defaults = false)
    grouped = {}
    attributes = metadata["attributes"].delete_if{|x,y| !y["recipes"].include?(recipe)}
    attributes.each_pair do |key,value|
      cookbook, attribute, subattribute = key.split("/")
      grouped[cookbook] = {} if grouped[cookbook].blank?
      if !subattribute.blank?
        grouped[cookbook][attribute] = [{}] if grouped[cookbook][attribute].blank?
        grouped[cookbook][attribute].first[subattribute] = defaults ? value["default"] : ""
      else
        grouped[cookbook][attribute] = defaults ? value["default"] : ""   if grouped[cookbook][attribute].blank?
      end


    end
    grouped
  end

end