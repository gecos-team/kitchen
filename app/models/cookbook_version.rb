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


  def multiple_attributes
    self.grouped_attributes.select{|x,y| !y[:principal].blank?}.map{|x| x[0]}
  end

  def initialize_attributes
    grouped = {}
    metadata["attributes"].each_pair do |key,value|
      cookbook, attribute, subattribute = key.split("/")
      grouped[cookbook] = {} if grouped[cookbook].blank?

      if !subattribute.blank?
        grouped[cookbook][attribute] = {} if grouped[cookbook][attribute].blank?
        grouped[cookbook][attribute][subattribute] = ""
      else
        grouped[cookbook][attribute] = ""  if grouped[cookbook][attribute].blank?
      end


    end
    grouped
  end

end