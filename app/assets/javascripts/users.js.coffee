# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

  # jQuery.validator.addMethod "complete_uri", (val,elem) ->
  #   /(smb|nfs|ftp):\/\/([\S]*)\/.*/.test(val);
  `jQuery.validator.addMethod("uri", function(val, elem) {
    return /(smb|nfs|ftp):\/\/([\S]*)\/.*/.test(val);
  }, "Please enter valid URI");`

  # jQuery.validator.addMethod "ip", (val,elem) ->
  #    /([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$/i.test(val);
  `jQuery.validator.addMethod("ip", function(val, elem) {
    return /([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$/i.test(val);
  }, "Please enter a valid IP x.x.x.x");`

  `jQuery.validator.addMethod("integer", function(val, elem) {
    return (val > 0 && val < 65536);
  }, "Please enter a valid number between 0 and 65335");`

  $("#edit_user").validate
    rules:
        ip: "ip"
        uri: "uri"
        integer:
          numeric: true
          integer: true
