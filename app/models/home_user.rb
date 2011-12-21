class HomeUser < ChefBase

  def initialize(attributes = {})
    attributes.each_pair { |key, value|
         metaclass.send :attr_accessor, key.gsub("?","")
         send "#{key.gsub("?","")}=".to_sym, value
       }
     @@attributes = attributes

     metaclass.send :attr_accessor, "databag"
     send "databag=".to_sym, Usermanagement.find_or_create(self.username)

  end




  def self.find(username)
    all = []
    Node.search("users_username:#{username}").each do |node|
      node_info = {:name => node.name, :hostname => node.hostname, :errors => node.error?}
      node.automatic["users"].map{|x| all << self.new(x.merge!({"nodes" => [node_info]})) if x["username"] == username}
    end
    return all.first if all.size == 1
    all
  end

  def self.all
    all = []
    Node.search("users:*").each do |node|
      node_info = {:name => node.name, :hostname => node.hostname, :errors => node.error?}
      node.automatic["users"].map{|x| all << self.new(x.merge!({"nodes" => [node_info]}))}
    end
    return all.first if all.size == 1
    all
  end

  def skel
    Cookbook.find("usermanagement").versions.last.grouped_attributes
  end

end