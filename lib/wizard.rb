module Wizard
  def self.text(wizard_name, node, skel, defaults, data)
    "Wizard::#{wizard_name.camelize}".constantize.new(node, skel, defaults, data).text
  end
end
