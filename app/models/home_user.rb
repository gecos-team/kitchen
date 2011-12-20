class HomeUser < ChefBase   


  
  def self.find(username)     
    all = []
    Node.search("users:#{username}").each do |node|
      node_info = {:name => node.name, :hostname => node.hostname, :errors => node.error?}
      node.automatic["users"].map{|x| all << self.new(x.merge!({"nodes" => [node_info]}))}
    end
    all
  end  
  
  def self.all
    self.find("*")
  end

end
