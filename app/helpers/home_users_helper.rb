module HomeUsersHelper

def render_base_attribute(field)
  out = ""
  field_title = field[0]

  if !field[1][:principal].blank?

    out << "<div id = #{field_title}_base class='hidden'>"
    out << "<div id = 'fields'>"
    field[1][:attributes].each do |x|
      out << render_attribute(x.keys.first, x.values.first, "", "base")
    end
    out << "</div>"
    out <<  "<div id = 'action'><a href='#' class=remove>#{image_tag('delete.png')}</a></div>"
    out << "<div class = 'clear'></div></div>"
  end

end

def render_fieldset(field,data,parent_name = "[databag]")
  field_title = field[0]
  out =  "<fieldset id = #{field_title}> <legend> #{field_title}"
  out << "(Multiple)" if !field[1][:principal].blank?
  out << "</legend>"

  if !field[1][:principal].blank?
    data[field[0]].each_with_index do |value,index|
      out << "<div id = #{field_title}_#{index}>"
      out << "<div id = 'fields'>"
      field[1][:attributes].each do |x|
        out << render_attribute(x.keys.first, x.values.first, value[x.keys.first.split("/")[2]], index, parent_name)
      end

      out << "</div>"
      out <<  "<div id = 'action'><a href='#' class=remove>#{image_tag('delete.png')}</a></div>"
      out << "<div class = 'clear'></div></div>"
    end
    # out << "<div id = #{field_title}_fill></div>"
    out << link_to_function(image_tag("add.png"), "clone_attribute('#{field_title}');", :class => "add")
  else

  field[1][:attributes].each do |x|
    out << render_attribute(x.keys.first, x.values.first, data[x.keys.first.split("/")[1]], nil, parent_name)
  end
end

  out << "</fieldset><br/>"
end

def render_attribute(key,properties,data = "",index = nil, parent_name = "[databag]")
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
   display_label += "* " if properties["required"]
   input_class = "required"if properties["required"]

   out << label_tag(key, display_label)

   if index.nil?
     field_id = key.split("/").map{|x| "[#{x}]"}.join
   else
     field_id = key.split("/").map{|x| "[#{x}]"}.insert(2, "[#{index}]").join
   end
    field_id = parent_name+ field_id

   if !properties["choice"].blank?
     out << select_tag(field_id, options_for_select(properties["choice"], data))
   else
     input_class += " #{properties["validation"]}"
     out << text_field_tag(field_id, data, {:class => input_class, :custom => properties["custom"]})
   end
   # out << "</p>"
   out << "<br/><i class = 'hint'>#{properties['description']}</i>"

end

end