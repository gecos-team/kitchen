class Databag < ChefBase  
 
  API_ROUTE = "/data"  

  def initialize(attributes = {}) 
    metaclass.send :attr_accessor, :name 
    name = attributes.keys.first
    send "name=".to_sym, name
    
    metaclass.send :attr_accessor, :url 
    send "url=".to_sym, attributes[name]    
  end
    
end
