class Node < ChefBase

  [:patform, :hostname, :ip].each do |method|
   define_method method do
      self.automatic["method"]
   end
  end


  def platform_version
    "#{self.automatic["platform"]} #{self.automatic["platform_version"]}"
  end


  def status
    self.automatic["uptime"].blank? ? "off" : "on"
  end

  def error?
    self.normal["last_run_error"]
  end

  def error
    self.normal["last_run_status_msg"]
  end

  def users
    self.automatic["users"].map {|u| u["username"] } if self.automatic["users"]
  end

  def users_list
    self.users.join(", ")
  end

  def self.find_by_user(user)
    self.class.find(:all, :user => user)
  end


  def self.search_by_role(name)
    ChefAPI.search_nodes_by_role(name)
  end


  def extended_run_list
    rl = []
    self.run_list.each{|x| rl << RunListItem.new(x)}
    rl
  end

  def avaiable_recipes
    Cookbook.all.map(&:recipes_name).flatten.map{|x| "recipe[#{x}]"} - self.run_list
  end

  def avaiable_roles
    Role.all.map(&:name).flatten.map{|x| "role[#{x}]"} - self.run_list
  end


  def add_to_role_and_save(role)
    rolename = Role.name_of_role(role)
    @run_list << rolename unless @run_list.include? rolename
    save
  end

  def del_from_role_and_save(role)
    rolename = Role.name_of_role(role)
    @run_list.delete(rolename)
    save
  end

end
