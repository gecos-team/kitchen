class Databag < ChefBase
  API_ROUTE = "/data"

  attr_accessor :name

  def initialize(attributes={})
    super(:value => attributes)
  end

  def empty?
    value.empty?
  end
end
