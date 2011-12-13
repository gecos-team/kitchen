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
  
end
