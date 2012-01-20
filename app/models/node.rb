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

  def available_packages
    [{:name => "apache2", :description => "web server"},
     {:name => "gimp", :description => "retoque fotografico"},
     {:name => "webrick", :description => "servidor web rapido"},
     {:name => "apache22", :description => "web server 22"},
     {:name => "gimp2", :description => "retoque fotografico 22"},
     {:name => "webrick2", :description => "servidor web rapido 22"},
     {:name => "apache23", :description => "web server 33"},
     {:name => "gimp3", :description => "retoque fotografico 33"},
     {:name => "webrick3", :description => "servidor web rapido 33"},
     {:name => "apache24", :description => "web server 44"},
     {:name => "gimp4", :description => "retoque fotografico 44"},
     {:name => "webrick4", :description => "servidor web rapido 44"}]

     databag = Databag.find("sources_list/#{node_repos}").value["packages"]

     node_repos = automatic["sources_list"].keys.first #HACER BUCLE



  end


  def search_package(q)
    re = Regexp.new("/*#{q}*", Regexp::IGNORECASE)
    self.available_packages.select{|x| x[:name].match(re) or x[:description].match(re)}

    data = [
      # Add below block for each category
      {
        :header => {
          :title =>  "Category Title",
          :num =>  "Number of results",
          :limit => "Number to display"
        },
        :data => [
          # Add below block for each result
          {
            :primary => "Title",
            :secondary => "Description (Optional)",
            :image => "URL (Optional)",
            :onclick => "JavaScript to execute when clicked (Optional)"
          }
        ]
      }
    ]

    return data


  end


end
