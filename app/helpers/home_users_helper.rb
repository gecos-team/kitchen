module HomeUsersHelper

def render_base_attribute(recipe_field, parent_name = "[databag]", node=nil)
  out = ""
  recipe_field[1].each do |field|
    field_title = field[0]
    if !field[1][:principal].blank?

      out << "<div id = #{field_title}_base class='hidden'>"
      out << "<div id = 'fields'>"
      field[1][:attributes].sort{|x,y| x.values.first["order"].to_i <=> y.values.first["order"].to_i}.each do |x|
        out << render_attribute(x.keys.first, x.values.first, "", "base", parent_name, false,node=node)
      end
      out << "</div>"
      out <<  "<div id = 'action'><a href='#' class=remove attribute=#{field_title}>#{image_tag('delete.png')}</a></div>"
      out << "<div class = 'clear'></div></div>"
    end
  end
  out
end

def recursive_hash(hash, hash_new)
  hash.each do |key, item|
    if item.class.name == "ActiveSupport::HashWithIndifferentAccess"
      item=item.to_hash
    end 
    if item.class.name == "String"
      hash_new.merge!({key=>item})
    elsif item.class.name == "Hash" and item.keys.first == item.keys.first.to_i.to_s
      hash_new.merge!({key=>item.values})
    elsif item.class.name == "Hash"
      hash_new.merge!({key=>recursive_hash(item, {})})
    end
  end
  return hash_new

end
module_function :recursive_hash



def render_fieldset(recipe_field,data,parent_name = "[databag]", defaults = [], use_default_data = false, node = nil)
  field_title = recipe_field[0]
  out =  "<fieldset id = #{field_title}> <legend> #{field_title}"
  # out << "(Multiple)" if !field[1][:principal].blank?
  out << "</legend>"
  recipe_field[1].sort{|x,y| x[1][:order] <=> y[1][:order]}.each do |field|
  attributes = field[1][:attributes]
  if !field[1][:principal].blank?
    attr_index = 0
    subattribute = field[1][:principal].keys.first.split("/").last
    attribute_mult = field[1][:principal].keys.first
    defaults = field[1][:principal][attribute_mult]['default']
    
    subattribute_data = data[subattribute]
    subattribute_data = subattribute_data.values if subattribute_data.class.name == "Hash"
    default_data = []
    if defaults != nil
      default_data = defaults
    end
    if subattribute_data.size == 1 and subattribute_data[0].values.first == "" and defaults != nil
      default_data.each do |value|
        
        out << "<div id = #{subattribute}_#{attr_index}>"
        out << "<div id = 'fields'>"
        attributes = attributes.sort{|x,y| x[x.keys.first]['order'] <=> y[y.keys.first]['order']}
        attributes.each do |x|
          out << render_attribute(x.keys.first, x.values.first, value[x.keys.first.split("/")[2]], attr_index, parent_name, use_default_data, node=node)
        end
        out << "</div>"
        out <<  "<div id = 'action'><a href='#' class=remove attribute=#{subattribute} >#{image_tag('delete.png')}</a></div>"
        out << "<div class = 'clear'></div></div>"
        attr_index+=1
      end
    else
      subattribute_data.each do |value|
     
        out << "<div id = #{subattribute}_#{attr_index}>"
        out << "<div id = 'fields'>"
        attributes = attributes.sort{|x,y| x[x.keys.first]['order'] <=> y[y.keys.first]['order']}
        attributes.each do |x|
 
          out << render_attribute(x.keys.first, x.values.first, value[x.keys.first.split("/")[2]], attr_index, parent_name, use_default_data, node=node)
        end
        out << "</div>"
        out <<  "<div id = 'action'><a href='#' class=remove attribute=#{subattribute} >#{image_tag('delete.png')}</a></div>"
        out << "<div class = 'clear'></div></div>"
        attr_index+=1

      end
    end
    # out << "<div id = #{field_title}_fill></div>"
    out << link_to_function(image_tag("add.png"), "clone_attribute('#{field_title}','#{subattribute}');", :class => "add")
    out << "<div class = 'clear'></div><hr/>"
  else
    attributes.each do |x|
      out << render_attribute(x.keys.first, x.values.first, data[x.keys.first.split("/")[1]], nil, parent_name, use_default_data,node=node)
    end
  end
end

  out << "</fieldset><br/>"
end

def render_attribute(key,properties,data = "",attr_index = nil, parent_name = "[databag]", use_default_data = false, node = nil)

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
   if properties["required"] == "required"
     input_class = "required"
   else
     input_class = "notrequired"
   end


   if attr_index.nil?
     field_id = key.split("/").map{|x| "[#{x}]"}.join
   else
     field_id = key.split("/").map{|x| "[#{x}]"}.insert(2, "[#{attr_index}]").join
   end

   field_id = parent_name + field_id


   if !properties["dependent"].nil?

     input_class << " has_dependents"
     field_index = field_id.gsub('][', '_').gsub('[', '').gsub(']', '')
     s_dependent = "<ul class=\"hidden dependent_#{field_index}\">"

     properties["dependent"].each do |dependent|
       field = dependent["field"]
       validator = dependent["validator"]
       field_suffix = field.split("/").join("_")
       s_dependent << "<li><span class=\"field\">#{field_suffix}</span><span class=\"validator\">#{validator}</span>"
     end

     s_dependent << '</ul>'
     out << s_dependent
   end

   out << label_tag(key, display_label)


   if !properties["wizard"].blank?
     out << render_wizard(field_id,properties,data,node=node)
   elsif !properties["choice"].blank?
     if !data.blank?
       out << select_tag(field_id, options_for_select(properties["choice"], data), {:class => input_class, :disabled => ("disabled" if use_default_data)})
     else
       out << select_tag(field_id, options_for_select(properties["choice"], default), {:class => input_class, :disabled => ("disabled" if use_default_data)})
     end
   else
     input_class += " #{properties["validation"]}"
     out << text_field_tag(field_id, data, {:class => input_class, :custom => properties["custom"], :default => (default if default), :disabled => ("disabled" if use_default_data)})


   end
   # out << "</p>"
   out << "<br><i class = 'hint'>#{properties['description']}</i></p>"

end


def render_wizard(field_id,properties,data = "",node=nil)

    case wizard = properties["wizard"]
    when "selector"
      render_selector_wizard(field_id, data, properties["source"])
    when "search"
      render_search_wizard(field_id, data)
    when "users"
      render_users_wizard(field_id, data, node=node)
    when "groups"
      render_groups_wizard(field_id, data, node=node)
   end
    
end


def render_selector_wizard(field_id, data, source)
  options = Databag.find(source).value.keys
  unless options == nil
    select_tag(field_id, options_for_select(options, data))
  end
end

def render_users_wizard(field_id, data, node)
  usernames = []
  unless node.automatic['users'] == nil 
    node.automatic['users'].each do |user|
      usernames << user['username']
    end
  end
  usernames << 'root'
  options = usernames.sort!
  unless options == nil
    select_tag(field_id, options_for_select(options, data))
  end
end


def render_groups_wizard(field_id, data, node)
  groups = []
  
  groups = node.automatic['etc']['group'].keys.sort!
  options = groups
  unless options == nil
    select_tag(field_id, options_for_select(options, data))
  end
end


def render_search_wizard(field_id, data)
  render :partial => "wizards/search", :locals => {:field_id => field_id, :packages => data}
end


end
