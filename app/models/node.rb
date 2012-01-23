class Node < ChefBase

  def before_save
    @run_list = (["recipe[ohai-gecos]"] + @run_list + Cookbook.find("usermanagement").recipes_list).flatten.uniq.compact
  end

  [:patform, :hostname, :ipaddress].each do |method|
   define_method method do
      self.automatic[method.to_s]
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
    @run_list.insert(1, rolename) unless @run_list.include?(rolename)
    save
  end

  def del_from_role_and_save(role)
    rolename = Role.name_of_role(role)
    @run_list.delete(rolename)
    save
  end

  def roles
    self.run_list.select{|x| x.split("[")[0] == "role"}.map do |role|
      Role.find(%r{^role\[([^\]]+)\]$}.match(role)[1])

    end
  end


  def self.find(q)
    nodes = Node.search("name:#{q}")
    if nodes.size == 1
      nodes.first
    else
      nodes
      end
  end

  def self.all
    Node.find("*")
  end



end
