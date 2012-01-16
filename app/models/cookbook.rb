class Cookbook < ChefBase

  HIDDEN = ["ohai", "usermanagement", "ohai-gecos"]


  def initialize(attributes = {})
    metaclass.send :attr_accessor, :name
    name = attributes.keys.first
    send "name=".to_sym, name

    metaclass.send :attr_accessor, :data
    send "data=".to_sym, attributes[name]
  end


  def versions
    versions = []
    path = "/cookbooks/#{self.name}/"

    self.data["versions"].each do |version|
      versions << CookbookVersion.new(ChefAPI.get(path+version["version"]))
    end

    versions

  end

  def versions_name
    self.data["versions"].map{|x| x["version"]}.join(",")
  end

  def recipes_name
    #TODO comprobar si hay mas versiones
    #HARDCODED: Si es del cookoook usermanagement no se muestra el "usermanagement::"
    # if self.name == "usermanagement"
    #     self.versions.first.metadata["recipes"].keys.map{|x| x.split("::")[1].nil? ? x.split("::")[0].upcase : x.split("::")[1]}
    #   else
    #     self.versions.first.metadata["recipes"].keys
    #   end
    self.versions.first.metadata["recipes"].keys
  end

  def recipes_list
    self.recipes_name.delete_if{|x| !x.include?("::")}.map{|x| "recipe[#{x}]"}
  end

  def self.is_advanced_recipe?(recipe)
    cookbook_name, recipe_name = recipe.split("::")
    cookbook = Cookbook.find(cookbook_name)
    return false if cookbook.blank?
    cookbook_attributes = cookbook.versions.first.metadata["attributes"]
    return false if cookbook_attributes.blank? or cookbook_name == "usermanagement"
    return true if cookbook_attributes.keys.map{|x| x.split("/")[0] == recipe_name}.include?(true) or (recipe_name.blank? and !cookbook_attributes.blank?)
  end

  def self.wizard_name(recipe)
    cookbook_name, recipe_name = recipe.split("::")
    cookbook = Cookbook.find(cookbook_name)
    return nil if cookbook.blank?
    attributes = cookbook.versions.first.metadata["attributes"]
    unless (wizard = attributes.find{ |name, meta| !meta["wizard"].nil? }).nil?
      # wizard is now something like:
      # ["printers/printers", {
      #    "required"=>"required",
      #    "calculated"=>false,
      #    "wizard"=>"printers",
      #    "default"=>[],
      #    "choice"=>[],
      #    "type"=>"array",
      #    "recipes"=>["printers::printers"],
      #    "display_name"=>"Printers: printers to setup",
      #    "description"=>"List of printer names"}]
      wizard[1]["wizard"]
    end
  end

  def self.skel_for(recipe)
    self.find(recipe).versions.first.grouped_attributes
  end

  def self.multiple_in_skel_for(recipe)
    self.find(recipe).versions.first.multiple_attributes
  end

  def self.initialize_attributes_for(recipe, defaults = false)
    Cookbook.find(recipe).versions.first.initialize_attributes(defaults)
  end

end
