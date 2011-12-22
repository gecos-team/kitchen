# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

  $(".remove").bind 'click', ->
    $(this).parent().remove()


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


  $("#edit_user").validate
    rules:
        ip: "ip"
        uri: "uri"
        integer:
          numeric: true
          integer: true


` function clone_attribute(attribute){

    fieldset = $("#"+attribute);
    field = $("#"+attribute+"_base");
    clone = field.clone();
    size = Number($("#shares").find("div").last().attr("id").split("_").pop())+1


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

    clone.insertAfter(fieldset.find("div").last())

    $(".remove").bind('click', function() {
      return $(this).parent().remove();
    });
};`