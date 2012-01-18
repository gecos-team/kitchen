module NodesHelper

  QUALIFIED_RECIPE             = %r{^recipe\[([^\]@]+)(@([0-9]+(\.[0-9]+){1,2}))?\]$}
  QUALIFIED_ROLE               = %r{^role\[([^\]]+)\]$}
  VERSIONED_UNQUALIFIED_RECIPE = %r{^([^@]+)(@([0-9]+(\.[0-9]+){1,2}))$}

  def normalize_item(item)


    if match = QUALIFIED_RECIPE.match(item)
      # recipe[recipe_name]
      # recipe[recipe_name@1.0.0]
      @type = :recipe
      @name = match[1]
      @version = match[3] if match[3]
    elsif match = QUALIFIED_ROLE.match(item)
      # role[role_name]
      @type = :role
      @name = match[1]
    elsif match = VERSIONED_UNQUALIFIED_RECIPE.match(item)
      # recipe_name@1.0.0
      @type = :recipe
      @name = match[1]
      @version = match[3] if match[3]
    else
      # recipe_name
      @type = :recipe
      @name = item
    end

      @name

  end



  def build_tree(name, node)
     html = "<table id='#{name}' class='full tree table'>"
     html << "<tr><th class='ui-state-default first'>Attribute</th><th class='ui-state-default last'>Value</th></tr>"
     count = 0
     parent = 0
     append_tree(name, html, node.to_json, count, parent)
     html << "</table>"
     html
   end

   def append_tree(name, html, node, count, parent)
     to_do = node
     index = 0
     #to_do = node.kind_of?(Chef::Node) ? node.attribute : node
     to_do.sort{ |a,b| a[0] <=> b[0] }.each do |key, value|
       to_send = Array.new
       count += 1
       index += 1
       is_parent = false
       local_html = ""
       odd = index.odd? ? "odd" : "even"
       local_html << "<tr id='#{name}-#{count}' class='collapsed #{name} #{odd}"
       if parent != 0
         local_html << " child-of-#{name}-#{parent}' style='display: none;'>"
         #local_html << " child-of-#{name}-#{parent}'>"
       else
         local_html << "'>"
       end
       local_html << "<td class='table-key'><span toggle='#{name}-#{count}'/>#{key}</td>"
       case value.class.name
       when "Hash"
         is_parent = true
         local_html << "<td></td>"
         p = count
         to_send << Proc.new { append_tree(name, html, value, count, p) } if !value.blank?
       when "Array"
         is_parent = true
         local_html << "<td></td>"
         as_hash = {}
         value.each_index { |i| as_hash[i] = value[i] }
         p = count
         to_send << Proc.new { append_tree(name, html, as_hash, count, p) } if !value.blank?
       else
         local_html << "<td><div class='json-attr'>#{value}</div></td>"
       end
       local_html << "</tr>"
       local_html.sub!(/class='collapsed/, 'class=\'collapsed parent') if is_parent
       local_html.sub!(/<span/, "<span class='expander'") if is_parent
       html << local_html
       to_send.each { |s| count = s.call }
       count += to_send.length
     end
     count
   end



end
