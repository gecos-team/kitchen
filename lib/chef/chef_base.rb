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
      send "#{key.gsub("?","")}=".to_sym, value
    }
    @new_record = true
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
    if @new_record
      create
    else
      update
    end
  end

  def delete
    self.class.delete(self.name)
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
    name = options["name"]
    ChefAPI.put("#{self.api_path}/#{name}", options)
  end

  def self.delete(name)
    ChefAPI.delete("#{self.api_path}/#{name}")
  end

  private

  def update
    self.class.update(self.instance_values)
  end

  def create
    ChefAPI.post(self.class.api_path, self.instance_values)
  end
end
