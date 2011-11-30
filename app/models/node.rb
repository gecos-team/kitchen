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
  
  def hostname
    self.automatic["hostname"]
  end   
  
  def running?
    self.automatic["uptime"].blank? ? false : true
  end 
  
  def error?
    self.normal["last_run_error"]
  end  
  
  def error
    self.normal["last_run_status_msg"]
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
