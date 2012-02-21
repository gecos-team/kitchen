require 'chef_api'

class ChefBase

  def metaclass
      class << self
        self
      end
    end

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Serializers::JSON

  API_ROUTE =  nil

  def initialize(attributes = {})
    attributes.each_pair { |key, value|
      metaclass.send :attr_accessor, key.to_s.gsub("?","")
      send "#{key.to_s.gsub("?","")}=".to_sym, value
    }
    @@attributes = attributes
    @new_record = true
  end

  def update_attributes(attributes={})
    attributes.each_pair { |key, value|
      method = "#{key.gsub("?","")}=".to_sym
      send method, value if respond_to? method
    }
    save
  end

  def id
    if @name
      @name
    else
      super
    end
  end

  def new_record?
    @new_record
  end

  def persisted?
    !@new_record
  end

  def to_json
    # path = '/' + self.class.name.to_s.downcase.pluralize + '/' + self.name
    ChefAPI.get(self.class.api_path + '/' + self.name)
  end

  def to_html
    yaml =  self.to_json.to_yaml
    html = yaml.gsub(/^--- \n/, "").gsub(/\S*:/){|i| "- #{i}"}
    BlueCloth.new(html).to_html

  end


  def save
    self.before_save if !defined?(self.before_save).nil?
    if @new_record
      create
    else
      update
    end
  end

  def delete
    self.class.delete(self.name)
  end

  def instance_values
    if (allowed = self.class.instance_variable_get :@allowed_attributes)
      super.slice *allowed
    else
      super
    end
  end

  def self.allowed_attributes(*attrs)
    @allowed_attributes = attrs.collect &:to_s
  end

  def self.instantiate(attributes={})
    object = new(attributes)
    object.instance_variable_set :@new_record, false
    object
  end

  def self.find(*arguments)
    # path = '/' + self.name.to_s.downcase.pluralize
    path = self.api_path

    if arguments.size == 1
      path += "/#{arguments.first}"
    else

      scope   = arguments.slice!(0)
      options = arguments.slice!(0) || {}

      if options[:name]
        id = options[:name].blank? ? arguments.first : options[:name]
        path += "/#{options[:name]}"
      end

    end

    begin
      self.instantiate ChefAPI.get(path)
    rescue Exception => e
      []
    end

  end

  def self.all(*args)
    # path = '/' + self.name.to_s.downcase.pluralize
    all = []
    results_chef = ChefAPI.get(self.api_path)
    results_chef.each_pair {|key, value| all <<  self.find(key)}
    all
  end

  def self.search(query)
    results = []

    index = self.name.to_s.downcase
    results_chef = ChefAPI.search(index,query)
    if results_chef.is_a? String
      response = Yajl.load results_chef
      raise ChefException, response["error"].join(", ")
    end
    results_chef["rows"].each {|x| results << self.instantiate(x)}
    results
  end

  def self.api_path
    self::API_ROUTE || ('/' + self.name.to_s.downcase.pluralize)
  end

  def self.create(attributes={})
    new(attributes).save
  end

  def self.update(options={})
    # path = '/' + self.name.to_s.downcase.pluralize
    name = options["name"] || options["id"]
    ChefAPI.put("#{self.api_path}/#{name}", options)
  end

  def self.delete(name)
    ChefAPI.delete("#{self.api_path}/#{name}")
  end

  def advanced_data_empty_for?(recipe)
    cookbook,recipe = recipe.split("::")
    data = self.class.name == "Node" ? self.normal : self.default_attributes
    # data = self.normal
    skel = Cookbook.initialize_attributes_for(cookbook)[recipe]
    return true if data[recipe].blank?
    skel == data[recipe]
  end

  def clean_advanced_data(recipe)
    cookbook,recipe = recipe.split("::")
    data = self.class.name == "Node" ? self.normal : self.default_attributes
    data[cookbook].delete(recipe)
    data.delete(cookbook) if data[cookbook].blank?
    self.save
  end


  def available_packages
    packages = []
    if self.automatic["sources_list"] != nil
      self.automatic["sources_list"].each do |repo|
        suite = repo[1]["suite"]
        repo_id = repo[0].gsub('http://','').gsub('.','_').gsub(':','_').gsub('/','_')
        begin
          databag = Databag.find("sources_list/#{repo_id}")
          repo[1]["components"].each do |component|
            packages << databag.value["packages"][suite][component]
          end
        rescue Exception => e
        end
      end
      packages.inject{|x,y| x.merge(y)}
    end
 #   packages

  end


  def search_package(q)
    re = Regexp.new("^.*#{q}.*$", Regexp::IGNORECASE)
    packages = self.available_packages
    if packages.empty?
      results = [["No results","Probably haven't any sourcelist or you are trying with a group instead of workstation"]]
      result_list = []
      results.each do |result|
        result_list << {:primary => result[0], :secondary => result[1]}
      end
    else
      results = packages.select{|x,y| x.match(re) or y.match(re)}
      result_list = []
      results.each do |result|
        result_list << {:primary => result[0], :secondary => result[1], :onclick => "append_selected('#{result[0]}')"}
      end
    end


    data = [
      # Add below block for each category
      {
        :header => {
          :title =>  "Search results",
          :num =>  results.size,
          :limit => results.size
        },
        :data => result_list
      }
    ]

    return data


  end



  private

  def update
    self.class.update(self.instance_values)
    self
  end

  def create
    ChefAPI.post(self.class.api_path, self.instance_values)
    self
  end
end

