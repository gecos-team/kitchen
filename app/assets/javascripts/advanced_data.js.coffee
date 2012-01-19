$(document).ready ->
  $('#facebox_overlay').unbind("click")
  $(".default").bind 'change', ->
    inputs = $(this).parents("form").find("input[type!='hidden'][type!='submit'][class != 'default']")
    if $(this).attr("class") != "default lock"
       $(this).addClass("lock")
       for input in inputs
         $(input).attr("disabled", "disabled")
         $(input).attr("value", $(input).attr("default"))
    else
      $(this).removeClass("lock")
      for input in inputs
        $(input).removeAttr("disabled")
        $(input).attr("value", "")
    false