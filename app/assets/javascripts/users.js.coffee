# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

  $(".remove").bind 'click', ->
    element = $(this).parent().parent()
    element.fadeOut 'slow', -> $(this).remove()


  jQuery.validator.addMethod "complete_uri",
    (val,elem) ->
      /(smb|nfs|ftp):\/\/([\S]*)\/.*/.test(val);
    "Please enter valid URI"



  jQuery.validator.addMethod "ip",
    (val,elem) ->
      /([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$/i.test(val);
    "Please enter a valid IP x.x.x.x"


  jQuery.validator.addMethod "integer",
    (val,elem) ->
      val > 0 && val < 65536
    "Please enter a valid number between 0 and 65335"

  jQuery.validator.addMethod "custom",
    (val, elem) ->
      exp = new RegExp($(elem).attr("custom"))
      exp.test(val)
    "This field is invalid"


  $("#edit_user, #edit_node_attributes, #edit_role_attributes").validate
    rules:
        custom: "custom"
        ip: "ip"
        uri: "uri"
        integer:
          numeric: true
          integer: true
    # submitHandler: (form) ->
    #   $("input.disabled").attr("disabled", "disabled")
    #   $(this).ajaxSubmit()
    #   return false

  $("input.disabled").click () ->
    $(this).removeClass("disabled")


` function clone_attribute(attribute){

    fieldset = $("#"+attribute);
    field = $("#"+attribute+"_base");
    clone = field.clone();
    size = Number($("#shares").children("div:not(.clear)").last().attr("id").split("_").pop())+1


    clone.find('input').each(function() {
      $(this).val('');
      $(this).attr("value", "");
      });

    new_div_name = clone.attr("id").replace(attribute+"_base", attribute+"_"+size);
    clone.attr("id",new_div_name)


    clone.find("select, input").each(function() {
      new_id = $(this).attr("id").replace("_base_", "_"+size+"_");
      new_name = $(this).attr("name").replace("[base]", "["+size+"]");
      $(this).attr("id",new_id);
      $(this).attr("name",new_name);
      });

    clone.hide()
    clone.removeClass()


    clone.insertAfter(fieldset.children("div").last())
    clone.fadeIn('slow')



    $(".remove").bind('click', function() {
      return $(this).parent().parent().fadeOut('slow', function(){
        $(this).remove();
        })
    });
};`