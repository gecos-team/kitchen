class CookbookVersion < ChefBase 

  def self.all 
    Cookbook.all.map(&:versions)
  end  
  
  def grouped_attributes  
    grouped = {}
    metadata["attributes"].each_pair do |key,value| 
      cookbook = key.split("/")[0]  
      grouped[cookbook] = {:principal => {}, :attributes => []} if grouped[cookbook].nil? 
      
      if value["type"] =="array"
        grouped[cookbook][:principal] = {key, value}
      else
        grouped[cookbook][:attributes]<< ({key, value})
      end
    end   
    grouped 
  end

end