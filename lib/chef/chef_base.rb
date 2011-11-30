require 'chef_api'     

class ChefBase

  def metaclass
      class << self
        self
      end
    end
  
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming  
  include ActiveModel::Serializers::JSON
    
  def initialize(attributes = {})      
    attributes.each_pair { |key, value|
         metaclass.send :attr_accessor, key.gsub("?","")
         send "#{key.gsub("?","")}=".to_sym, value
       }    
  end
  
  def persisted?
    false
  end 
  
  
  def self.find(*arguments)  
    
    path = '/' + self.name.to_s.downcase.pluralize
    
    if arguments.size == 1  
      path += "/#{arguments.first}" 
    else
      
      scope   = arguments.slice!(0)
      options = arguments.slice!(0) || {}  
    
      if options[:name]
        id = options[:name].blank? ? arguments.first : options[:name] 
        path += "/#{options[:name]}"
      end  
         
    end   
        
    begin
      self.new ChefAPI.get(path)
    rescue Exception => e
      []
    end
      
  end 
       
  def self.all(*args)
    path = '/' + self.name.to_s.downcase.pluralize
    all = []     
    results_chef = ChefAPI.get(path)   
    results_chef.each_pair {|key, value| all <<  self.find(key)}
    all 
  end    
  
  def self.search(query)    
    results = []
    index = self.name.to_s.downcase 
    results_chef = ChefAPI.search(index,query) 
    results_chef["rows"].each {|x| results << self.new(x)}
    results
  end      
  

end