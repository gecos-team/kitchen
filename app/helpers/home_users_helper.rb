module HomeUsersHelper

def render_base_attribute(field, parent_name = "[databag]")
  out = ""
  field_title = field[0]

  if !field[1][:principal].blank?

    out << "<div id = #{field_title}_base class='hidden'>"
    out << "<div id = 'fields'>"
    field[1][:attributes].sort{|x,y| x.values.first["order"].to_i <=> y.values.first["order"].to_i}.each do |x|
      out << render_attribute(x.keys.first, x.values.first, "", "base", parent_name)
    end
    out << "</div>"
    out <<  "<div id = 'action'><a href='#' class=remove>#{image_tag('delete.png')}</a></div>"
    out << "<div class = 'clear'></div></div>"
  end
  out
end

def render_fieldset(field,data,parent_name = "[databag]", defaults = [])

  field_title = field[0]
  out =  "<fieldset id = #{field_title}> <legend> #{field_title}"
  out << "(Multiple)" if !field[1][:principal].blank?
  out << "</legend>"

  if !field[1][:principal].blank?
    attr_index = 0
    data[field[0]] = data[field[0]].values if data[field[0]].class.name == "Has"
    data[field[0]].each do |value|
      out << "<div id = #{field_title}_#{attr_index}>"
      out << "<div id = 'fields'>"
      field[1][:attributes].sort{|x,y| x.values.first["order"].to_i <=> y.values.first["order"].to_i}.each do |x|
        out << render_attribute(x.keys.first, x.values.first, value[x.keys.first.split("/")[2]], attr_index, parent_name)
      end

      out << "</div>"
      out <<  "<div id = 'action'><a href='#' class=remove>#{image_tag('delete.png')}</a></div>"
      out << "<div class = 'clear'></div></div>"
      attr_index+=1
    end
    # out << "<div id = #{field_title}_fill></div>"
    out << link_to_function(image_tag("add.png"), "clone_attribute('#{field_title}');", :class => "add")
  else

  field[1][:attributes].sort{|x,y| x.values.first["order"].to_i <=> y.values.first["order"].to_i}.each do |x|
    out << render_attribute(x.keys.first, x.values.first, data[x.keys.first.split("/")[1]], nil, parent_name)
  end
end

  out << "</fieldset><br/>"
end

def render_attribute(key,properties,data = "",attr_index = nil, parent_name = "[databag]")
   input_class = ""
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

   if (data == "" and !properties["default"].blank?)
     data = properties["default"]
     #input_class += " disabled"
     disabled = true

   end

   out << label_tag(key, display_label)

   if attr_index.nil?
     field_id = key.split("/").map{|x| "[#{x}]"}.join
   else
     field_id = key.split("/").map{|x| "[#{x}]"}.insert(2, "[#{attr_index}]").join
   end
    field_id = parent_name+ field_id

   if !properties["choice"].blank?
     out << select_tag(field_id, options_for_select(properties["choice"], data))
   else
     input_class += " #{properties["validation"]}"
     out << text_field_tag(field_id, data, {:class => input_class, :custom => properties["custom"], :disabled => ("disabled" if disabled)})
     # if disabled
     #   out << image_tag("lock.png", :class => "lock_icon")
     # end
   end
   # out << "</p>"
   out << "<br/><i class = 'hint'>#{properties['description']}</i></p>"

end

end
