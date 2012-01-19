class Printer
  include ActiveRecord::Validations

  validate do |printer|
    if printer.make.present? and printer.model.present?
      printers = Databag.find("printers")
      models = Databag.find("printers/#{printer.make}")
      if printers.empty? or models.empty? or
          !printers.value.keys.include? printer.make or
          !models.value.keys.include? printer.model
        errors.add(:base, I18n.t("errors.messages.printer.invalid_make_or_model"))
      end
    end

    available = Databag.find("available_printers")
    if printer.new_record? and !available.empty? and available.value.keys.include? printer.name.gsub(' ', '_')
      errors.add(:name, I18n.t("activerecord.errors.messages.taken"))
    end
  end
  validates_presence_of :name, :make, :model, :uri
  validates_format_of :uri, :with => URI::regexp

  attr_accessor :name, :make, :model, :ppd, :uri, :ppd_uri

  # required for rails view helpers
  def self.model_name
    ActiveModel::Name.new(self)
  end

  # Required for rails view helpers
  def to_key
    nil
  end

  # Required for validations
  def new_record?
    @new_record
  end

  def to_s
    name
  end

  def initialize(attributes={})
    attributes.each_pair { |k, v|
      next unless ["id", "name", "make", "model", "ppd", "uri", "ppd_uri"].include? k.to_s
      if k.to_s == "id"
        self.name = v
      else
        self.send "#{k}=", v
      end
    }
    @name ||= ""
    @new_record = true
  end

  def self.instantiate(attributes)
    object = new(attributes)
    object.instance_variable_set :@new_record, false
    object
  end

  def update_attributes(attributes)
    attributes.each_pair { |k, v|
      next unless [ "uri", "make", "model" ].include? k.to_s
      self.send "#{k}=", v
    }
  end

  def create!
    if (printers = Databag.find("available_printers")).blank?
      Spice::DataBag.create(:name => "available_printers")
    end
    v = Spice::DataBag.create_item(:name => "available_printers",
                                   :id => self.name.gsub(" ", "_"),
                                   :uri => self.uri,
                                   :make => self.make,
                                   :model => self.model,
                                   :ppd => self.ppd,
                                   :ppd_uri => self.ppd_uri)
    self.class.check_return_value(v)
    @new_record = false
    true
  end

  def save!
    v = Spice::DataBag.update_item(:name => "available_printers",
                                   :id => self.name.gsub(" ", "_"),
                                   :uri => self.uri,
                                   :make => self.make,
                                   :model => self.model,
                                   :ppd => self.ppd,
                                   :ppd_uri => self.ppd_uri)
    self.class.check_return_value(v)
  end

  def self.delete!(id)
    v = Spice::DataBag.delete_item(:name => "available_printers", :id => id.gsub(" ", "_"))
    check_return_value(v)
  end

  private

  def self.check_return_value(value)
    if value.is_a? String
      response = Yajl.load value
      raise ChefException, response["error"].join(", ")
    end
    value
  end
end
