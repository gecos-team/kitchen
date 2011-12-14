class HomeUser < ChefBase   


  
  def self.find(username)     
    all = []
    Node.search("home_users:#{username}").each do |node|
       node_info = {:name => node.name, :hostname => node.hostname, :errors => node.error?}
       node.automatic["home_users"].values.map{|x| all << self.new(x.merge!({"nodes" => [node_info]}))}
    end
    all
  end  
  
  def self.all
    self.find("*")
  end

end