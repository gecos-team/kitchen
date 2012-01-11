class Databag < ChefBase
  API_ROUTE = "/data"

  def initialize(attributes)
    super(:value => attributes)
  end
end
