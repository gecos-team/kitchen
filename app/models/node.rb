class Node < ChefBase

  def platform
    self.automatic["platform"]
  end
  
  def platform_version 
    "#{self.automatic["platform"]} #{self.automatic["platform_version"]}"
  end     
  
  def ip
    self.automatic["ipaddress"]
  end    
  
  def running?
    self.automatic["uptime"].blank? ? false : true
  end 
  
  def self.find_by_user(user) 
    self.class.find(:all, :user => user)
  end
  
  
  def extended_run_list
    rl = []
    self.run_list.each{|x| rl << RunListItem.new(x)}
    rl    
  end   
  
  
  
end
