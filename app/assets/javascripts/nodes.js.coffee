# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready -> 
    
   $("#run-list ul").sortable 
     connectWith: ["#recipes ul", "#roles ul"],
     dropOnEmpty: true  

   $("#roles ul").sortable
     connectWith: "#run-list ul",
     items: ".role",
     dropOnEmpty: true
     receive: (e, ui) -> 
       ui.sender.sortable('cancel') if not ui.item.context.classList.contains("role")    
	
   $("#recipes ul").sortable
     connectWith: "#run-list ul",
     items: ".recipe", 
     dropOnEmpty: true
     receive: (e, ui) -> 
       ui.sender.sortable('cancel') if not ui.item.context.classList.contains("recipe")   
    
   $("#run-list ul").disableSelection()
   $("#run-list ul").disableSelection()
   $("#run-list ul").disableSelection()   
   
   $("#tabs").tabs() 	
   
   $("form#edit_node, form.edit_group").submit (event) ->    
     form = $(this) 
     to_node = $('#run-list ul').sortable('toArray')
     for field in to_node   
       form.append('<input type="hidden" name="for_node[]" value="' + field + '"/>')    


   
   $(".toggle .ui-icon").click () ->
     $(this).toggleClass("ui-icon-triangle-1-e ui-icon-triangle-1-s")
     $(this).parents().next('.toggable').slideToggle("fast")  

   $('#tree').jstree
     json_data:
       ajax:
        url: "http://localhost:3000/nodes/localhost.json"
