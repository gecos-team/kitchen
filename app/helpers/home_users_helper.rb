module HomeUsersHelper

def render_base_attribute(recipe_field, parent_name = "[databag]")
  out = ""
  recipe_field[1].each do |field|
    field_title = field[0]
    if !field[1][:principal].blank?

      out << "<div id = #{field_title}_base class='hidden'>"
      out << "<div id = 'fields'>"
      field[1][:attributes].sort{|x,y| x.values.first["order"].to_i <=> y.values.first["order"].to_i}.each do |x|
        out << render_attribute(x.keys.first, x.values.first, "", "base", parent_name)
      end
      out << "</div>"
      out <<  "<div id = 'action'><a href='#' class=remove attribute=#{field_title}>#{image_tag('delete.png')}</a></div>"
      out << "<div class = 'clear'></div></div>"
    end
  end
  out
end

def render_fieldset(recipe_field,data,parent_name = "[databag]", defaults = [], use_default_data = false)

  field_title = recipe_field[0]
  out =  "<fieldset id = #{field_title}> <legend> #{field_title}"
  # out << "(Multiple)" if !field[1][:principal].blank?
  out << "</legend>"

  recipe_field[1].sort{|x,y| x[1][:order] <=> y[1][:order]}.each do |field|
  attributes = field[1][:attributes]

  if !field[1][:principal].blank?
    attr_index = 0
    subattribute = field[1][:principal].keys.first.split("/").last
    subattribute_data = data[subattribute]
    subattribute_data = subattribute_data.values if subattribute_data.class.name == "Hash"
    subattribute_data.each do |value|
      out << "<div id = #{subattribute}_#{attr_index}>"
      out << "<div id = 'fields'>"
      attributes.each do |x|
        out << render_attribute(x.keys.first, x.values.first, value[x.keys.first.split("/")[2]], attr_index, parent_name, use_default_data)
      end

      out << "</div>"
      out <<  "<div id = 'action'><a href='#' class=remove attribute=#{subattribute} >#{image_tag('delete.png')}</a></div>"
      out << "<div class = 'clear'></div></div>"
      attr_index+=1
    end
    # out << "<div id = #{field_title}_fill></div>"
    out << link_to_function(image_tag("add.png"), "clone_attribute('#{field_title}','#{subattribute}');", :class => "add")
    out << "<div class = 'clear'></div><hr/>"
  else
  attributes.each do |x|
    out << render_attribute(x.keys.first, x.values.first, data[x.keys.first.split("/")[1]], nil, parent_name, use_default_data)
  end
end
end

  out << "</fieldset><br/>"
end

def render_attribute(key,properties,data = "",attr_index = nil, parent_name = "[databag]", use_default_data = false)

   input_class = ""

   if !properties["default"].blank?
     default = properties["default"]
     #input_class += " disabled"
   end

   if use_default_data
     data = properties["default"]
   end

   data = "" if data.blank?
   size = case data.size
   when 1..10
     out = "<p class = 'short'>"
   when 10..40
     out = "<p class = 'medium'>"
   when 40..80
     out = "<p class = 'long'>"
   when 80..200
     out = "<p class = 'giant'>"
   else
     out = "<p class = 'medium'>"
   end

   display_label = properties["display_name"]
   display_label += "* " if properties["required"] == "required"
   input_class = "required" if properties["required"] == "required"

   out << label_tag(key, display_label)

   if attr_index.nil?
     field_id = key.split("/").map{|x| "[#{x}]"}.join
   else
     field_id = key.split("/").map{|x| "[#{x}]"}.insert(2, "[#{attr_index}]").join
   end
    field_id = parent_name+ field_id



   if !properties["wizard"].blank?
     out << render_wizard(field_id,properties,data)
   elsif !properties["choice"].blank?
     out << select_tag(field_id, options_for_select(properties["choice"], data), {:disabled => ("disabled" if use_default_data)})
   else
     input_class += " #{properties["validation"]}"
     out << text_field_tag(field_id, data, {:class => input_class, :custom => properties["custom"], :default => (default if default), :disabled => ("disabled" if use_default_data)})


   end
   # out << "</p>"
   out << "<br><i class = 'hint'>#{properties['description']}</i></p>"

end


def render_wizard(field_id,properties,data = "")

    case wizard = properties["wizard"]
    when "selector"
      render_selector_wizard(field_id, data, properties["source"])
    when "search"
      render_search_wizard(field_id)
    end

end


def render_selector_wizard(field_id, data, source)
  options = Databag.find(source).value.keys
  select_tag(field_id, options_for_select(options, data))
end

def render_search_wizard(field_id)
  render :partial => "wizards/search", :locals => {:field_id => field_id}
end


end
