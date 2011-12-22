module HomeUsersHelper

def render_base_attribute(field)
  out = ""
  field_title = field[0]

  if !field[1][:principal].blank?

    out << "<div id = #{field_title}_base class='hidden'>"
    field[1][:attributes].each do |x|
      out << render_attribute(x.keys.first, x.values.first, "", "base")
    end
    out <<  "<a href='#' class=remove>Delete</a>"
    out << "</div>"
  end

end

def render_fieldset(field,data)
  field_title = field[0]
  out =  "<fieldset id = #{field_title}> <legend> #{field_title}"
  out << "(Multiple)" if !field[1][:principal].blank?
  out << "</legend>"

  if !field[1][:principal].blank?
    data[field[0]].each_with_index do |value,index|
      out << "<div id = #{field_title}_#{index}>"
      field[1][:attributes].each do |x|
        out << render_attribute(x.keys.first, x.values.first, value[x.keys.first.split("/")[2]], index)
      end
      out <<  "<a href='#' class=remove>Delete</a>"
      out << "</div>"
    end
    # out << "<div id = #{field_title}_fill></div>"
    out << link_to_function ("Add new", "clone_attribute('#{field_title}');")
  else

  field[1][:attributes].each do |x|
    out << render_attribute(x.keys.first, x.values.first, data[x.keys.first.split("/")[1]])
  end
end

  out << "</fieldset><br/>"
end

def render_attribute(key,properties,data = "",index = nil)
   size = case data.size
   when 0..10
     out = "<p class = 'short'>"
   when 10..40
     out = "<p class = 'medium'>"
   when 40..80
     out = "<p class = 'long'>"
   when 80..200
     out = "<p class = 'giant'>"
   else
     out = "<p>"
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
    field_id = "[databag]"+ field_id

   if !properties["choice"].blank?
     out << select_tag(field_id, options_for_select(properties["choice"], data))
   else
     input_class += " #{properties["validation"]}"
     out << text_field_tag(field_id, data, :class => input_class)
   end

   out << "<p class = 'hint'>#{properties['description']}</p></p>"


end

end