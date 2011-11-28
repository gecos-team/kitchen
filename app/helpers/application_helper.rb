module ApplicationHelper    
  
  def convert_newline_to_br(string)
    string.to_s.gsub(/\n/, '<br />') unless string.nil?
  end
  
end
