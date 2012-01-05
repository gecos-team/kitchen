class Role < ChefBase
  allowed_attributes :name, :chef_type, :json_class, :default_attributes, :description, :run_list, :override_attributes

  def before_save
    @run_list = (["recipe[ohai-gecos]"] + @run_list).flatten.uniq.compact
  end

  def initialize(attributes={})
    attributes = {
      "name"                => nil,
      "chef_type"           => "role",
      "json_class"          => "Chef::Role",
      "default_attributes"  => {},
      "description"         => nil,
      "run_list"            => [],
      "override_attributes" => {}
    }.merge(attributes)
    super(attributes)
  end

  def node_list
    @node_list || nodes.collect(&:name)
  end

  def node_list=(new_node_list)
    old_nodes = nodes.collect &:name

    add_role = (new_node_list - old_nodes).collect { |name| Node.find(name) }
    del_role = (old_nodes - new_node_list).collect { |name|
      nodes.find { |node| node.name == name }
    }

    add_role.each { |node| node.add_to_role_and_save(self) }
    del_role.each { |node| node.del_from_role_and_save(self) }
  end

  def nodes(use_cache=true)
    return @nodes if @nodes and use_cache
    return [] if @name.blank?
    @nodes = Node.search_by_role(@name)
  end

  def available_roles
    Role.all.map(&:name).flatten.map{|x| "role[#{x}]"} - self.run_list
  end

  def available_recipes
    Cookbook.all.map(&:recipes_name).flatten.map{|x| "recipe[#{x}]"} - self.run_list
  end

  def extended_run_list
    rl = []
    self.run_list.each{|x| rl << RunListItem.new(x)}
    rl.flatten.uniq
  end

  def self.name_of_role(role)
    name = case role
           when Role
             role.name
           else
             role
           end
    "role[#{name}]"
  end

  def self.delete(name)
    super
    Node.search_by_role(name).each { |node| node.del_from_role_and_save(name) }
  end


  def assign_nodes(new_node_list)
    old_nodes = nodes.collect &:name

    add_role = (new_node_list - old_nodes).collect { |name| Node.find(name) }
    del_role = (old_nodes - new_node_list).collect { |name|
      nodes.find { |node| node.name == name }
    }

    add_role.each { |node| node.add_to_role_and_save(self) }
    del_role.each { |node| node.del_from_role_and_save(self) }
  end

end
