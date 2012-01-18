class Printer
  include ActiveRecord::Validations

  validate do |printer|
    available = Databag.find("available_printers")
    if !available.empty? and available.value.keys.include? printer.name.gsub(' ', '_')
      errors.add(:name, I18n.t("activerecord.errors.messages.taken"))
    end
  end
  validates_presence_of :name, :make, :model, :uri

  attr_accessor :name, :make, :model, :ppd, :uri

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
    true
  end

  def initialize(attributes={})
    { "name" => "" }.merge(attributes).each_pair { |k, v|
      self.send "#{k}=", v
    }
  end

  def create
    if (printers = Databag.find("available_printers")).blank?
      Spice::DataBag.create(:name => "available_printers")
    end
    Spice::DataBag.create_item(:name => "available_printers",
                               :id => self.name.gsub(" ", "_"),
                               :make => self.make,
                               :model => self.model,
                               :ppd => self.ppd,
                               :uri => self.uri)
    true
  end
end
