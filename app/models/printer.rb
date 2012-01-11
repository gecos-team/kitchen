class Printer
  include ActiveRecord::Validations

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
end
