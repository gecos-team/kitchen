class ChefAPI


  def self.connect
    if !@connection
      configfile = File.join(Rails.root,"config","chef.yml")
      if File.exists? configfile
        config = YAML.load_file(configfile)[Rails.env]
        uri = URI.parse(config["uri"])
        Spice.setup do |s|
          s.host = uri.host
          s.port = uri.port
          s.scheme = uri.scheme
          s.client_name = config["client_name"]
          s.key_file = config["keyfile"]
        end
      end
      Spice.connect!
    end
    @connection = Spice.connection
  end


  def self.get(*args)
    self.connect if !@connection
    @connection.get(*args)
  end

  def self.delete(*args)
    self.connect if !@connection
    @connection.delete(*args)
  end

  def self.post(*args)
    self.connect if !@connection
    @connection.post(*args)
  end

  def self.put(*args)
    self.connect if !@connection
    @connection.put(*args)
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

  def self.create(options={})
    raise ArgumentError, "Option :name must be present" unless options[:name]
    self.post("/clients", options)
  end


  def self.delete(options={})
    raise ArgumentError, "Option :name must be present" unless options[:name]
    path = '/' + self.name.to_s.downcase.pluralize
    name = options.delete(:name)
    self.delete("/#{path}/#{name}", options)
  end

  def self.search(index,query)
    self.connect
    Spice::Search.search(index, query)
  end




end