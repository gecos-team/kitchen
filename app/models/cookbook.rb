class Cookbook < ChefBase       
  
  
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
  
end