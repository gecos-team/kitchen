class CookbookVersion < ChefBase 

  def self.all 
    Cookbook.all.map(&:versions)
  end

end