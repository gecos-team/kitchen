module Wizard
  class Printers
    include ActionView::Helpers::AssetTagHelper::JavascriptTagHelpers

    def initialize(node, skel, defaults, data)
      @node = node
      @skel = skel
      @defaults = defaults
      @data = data
    end

    def text
      debugger
      template = <<EOT
= javascript_include_tag :users
#attr_base
  - @skel.each do |attribute|
    = raw render_base_attribute(attribute)

= form_tag node_path(@node.name), :method => :put, :id => "edit_node_attributes", :remote => true do
  - @skel.each do |attribute|
    = raw render_fieldset(attribute, @data[attribute[0]], "[node][normal]", @defaults)

  = submit_tag
EOT
      haml_engine = Haml::Engine.new(template)
      haml_engine.render(self)
    end
  end
end
