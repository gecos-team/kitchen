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
		
   
    