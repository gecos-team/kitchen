class Group < ActiveRecord::Base
  
  serialize :nodes_list, Array
  
  validates_presence_of :name, :nodes
  
  extend FriendlyId
  friendly_id :name, :use => :slugged
  
  def nodes 
    nodes = []
    self.nodes_list.each{|n| nodes << Node.find(n)}  
    nodes
  end
  
  
  [:run_list, :roles].each do |method|
   define_method method do
      list = []
      self.nodes.each{|n| list << n.send(method.to_s)}
      list.inject(:&)
   end
  end 
  
  def extended_run_list   
    rl = []
    self.run_list.each{|x| rl << RunListItem.new(x)}
    rl.flatten.uniq
  end  
  
  
  def avaiable_recipes
    Cookbook.all.map(&:recipes_name).flatten.map{|x| "recipe[#{x}]"} - self.run_list
  end 
  
  def avaiable_roles
    Role.all.map(&:name).flatten.map{|x| "role[#{x}]"} - self.run_list
  end
  
end
