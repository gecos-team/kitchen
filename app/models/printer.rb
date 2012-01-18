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

  def initialize(attributes={})
    { "name" => "" }.merge(attributes).each_pair { |k, v|
      next unless ["id", "name", "make", "model", "ppd", "uri", "ppd_uri"].include? k.to_s
      if k.to_s == "id"
        self.name = v
      else
        self.send "#{k}=", v
      end
    }
    @new_record = true
  end

  def self.instantiate(attributes)
    object = new(attributes)
    object.instance_variable_set :@new_record, false
    object
  end

  def create
    if (printers = Databag.find("available_printers")).blank?
      Spice::DataBag.create(:name => "available_printers")
    end
    Spice::DataBag.create_item(:name => "available_printers",
                               :id => self.name.gsub(" ", "_"),
                               :uri => self.uri,
                               :make => self.make,
                               :model => self.model,
                               :ppd => self.ppd,
                               :ppd_uri => self.ppd_uri)
    @new_record = false
    true
  end
end
