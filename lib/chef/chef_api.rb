module ChefAPI
  def self.connect
    if !@connection
      config = configuration
      @couchdb = config["couchdb"]
      uri = URI.parse(config["uri"])
      Spice.setup do |s|
        s.host = uri.host
        s.port = uri.port
        s.scheme = uri.scheme
        s.client_name = config["client_name"]
        s.key_file = config["keyfile"]
      end
      Spice.connect!
    end
    @connection = Spice.connection
  end

  def self.configuration
    return @config if @config
    configfile = File.join(Rails.root, "config", "chef.yml")
    @config = if File.exists? configfile
                YAML.load_file(configfile)[Rails.env]
              else
                {}
              end
  end

  def self.get(*args)
    self.connect if !@connection
    self.check_return_value @connection.get(*args)
  end

  def self.delete(*args)
    self.connect if !@connection
    self.check_return_value @connection.delete(*args)
  end

  def self.post(*args)
    self.connect if !@connection
    self.check_return_value @connection.post(*args)
  end

  def self.put(*args)
    self.connect if !@connection
    self.check_return_value @connection.put(*args)
  end


  def self.check_return_value(value)
    if value.is_a? String
      response = Yajl.load value
      raise ChefException, response["error"].join(", ")
    end
    value
  end


  def self.find(*arguments)
    scope   = arguments.slice!(0)
    options = arguments.slice!(0) || {}

    path = '/' + self.name.to_s.downcase.pluralize
    if options[:name]
      path = path + "/#{options[:name]}"
    end
    self.get(path)
  end

  def self.all(*args)
    self.find(:all, *args)
  end

  def self.destroy(options={})
    raise ArgumentError, "Option :name must be present" unless options[:name]
    path = '/' + self.name.to_s.downcase.pluralize
    name = options.delete(:name)
    self.delete("/#{path}/#{name}", options)
  end

  def self.search(index,query)
    self.connect
    Spice::Search.search(index, query)
  end

  def self.search_nodes_by_role(name)
    if @couchdb
      begin
        response = RestClient.get("#{@couchdb}/_design/nodes/_view/by_run_list",
                                  :params => {:key => %Q{"role[#{name}]"}})
        return Yajl.load(response.body)["rows"].collect { |attrs| Node.find(attrs["value"]) }
      rescue => e
        e.response
      end
    else
      Node.search("role:#{name}")
    end
  end
end
