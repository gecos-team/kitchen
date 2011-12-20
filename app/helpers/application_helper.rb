module ApplicationHelper    
  
  def convert_newline_to_br(string)
    string.to_s.gsub(/\n/, '<br />') unless string.nil?
  end      
  
  
  def render_fieldset(field,data)  
    out =  "<fieldset> <legend> #{field[0]}"
    out << "(Multiple)" if !field[1][:principal].blank? 
    out << "</legend>" 
    
    if !field[1][:principal].blank?    
      data[field[0]].each_with_index do |value,index| 
        field[1][:attributes].each do |x|
          out << render_attribute(x.keys.first, x.values.first, value[x.keys.first.split("/")[2]], index)
        end
      end
    else
    
    field[1][:attributes].each do |x|  
      out << render_attribute(x.keys.first, x.values.first, data[x.keys.first.split("/")[1]])
    end 
  end
    
    out << "</fieldset><br/>"     
  end
  
  def render_attribute(key,properties,data,index = nil)
     
     out = ""
     
     out << label_tag(key, properties["display_name"]) 
     
     if index.nil?
       field_id = key.split("/").map{|x| "[#{x}]"}.join
     else
       field_id = key.split("/").map{|x| "[#{x}]"}.insert(2, "[#{index}]").join
     end 
      field_id = "[databag]"+ field_id
     
     if !properties["choice"].blank?
       out << select_tag(field_id, options_for_select(properties["choice"], data))
     else
       out << text_field_tag(field_id, data)
     end
        
     
     out << "<br/>"
       
  end      
  
  

  
end