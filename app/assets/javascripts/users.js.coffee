# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

  $(".remove").bind 'click', ->
    element = $(this).parent().parent()
    att = $(this).attr("attribute");
    if ($("div[id^="+att+"][class!='hidden']").size() == 1)
      $(this).parent().parent().find("input[type!='hidden'][type!='submit'][class != 'default']").attr("value", "")
    else
      element.fadeOut 'slow', -> $(this).remove()


  jQuery.validator.addMethod "complete_uri",
    (val,elem) ->
      /(smb|nfs|ftp):\/\/([\S]*)\/.*/.test(val);
    "Please enter valid URI"

  jQuery.validator.addMethod "printer_uri",
    (val,elem) ->
      /(((smb|http|ipp|ldp|socket):\/\/)|((serial[0-9]*|usb[0-9]*):\/))([\S]*)\/.*/.test(val);
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

  `jQuery.validator.addMethod("letterswithbasicpunc", function(value, element) {
    return this.optional(element) || /^[a-z-.,()'\''\s]+$/i.test(value);
  }, "Letters or punctuation only please");

  jQuery.validator.addMethod("alphanumeric", function(value, element) {
    return this.optional(element) || /^\w+$/i.test(value);
  }, "Letters, numbers, spaces or underscores only please");

  jQuery.validator.addMethod("alphanumericwithdots", function(value, element) {
    return this.optional(element) || /^((\w)|\.)+$/i.test(value);
  }, "Letters, numbers, spaces, underscores or dots only please");


  jQuery.validator.addMethod("lettersonly", function(value, element) {
    return this.optional(element) || /^[a-z]+$/i.test(value);
  }, "Letters only please");

  jQuery.validator.addMethod("nowhitespace", function(value, element) {
    return this.optional(element) || /^\S+$/i.test(value);
  }, "No white space please");

  jQuery.validator.addMethod("time", function(value, element) {
    return this.optional(element) || /^([01]\d|2[0-3])(:[0-5]\d){0,2}$/.test(value);
  }, "Please enter a valid time, between 00:00 and 23:59");
  jQuery.validator.addMethod("time12h", function(value, element) {
    return this.optional(element) || /^((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))$/i.test(value);
  }, "Please enter a valid time, between 00:00 am and 12:00 pm");
  jQuery.validator.addMethod("abspath", function(value, element) {
    return this.optional(element) || /^(\/).+$/i.test(value);
  }, "Please enter a valid path");
  jQuery.validator.addMethod("modefile", function(value, element) {
    return this.optional(element) || /^[0|1|2|4][0-7][0-7][0-7]$/i.test(value);
  }, "Please enter a valid mode of file (in e.g 0644,0775..)");
  jQuery.validator.addMethod("timespan", function(value, element) {
    return this.optional(element) || /^([0-9][0-9][0-9])$/i.test(value);
  }, "Please enter a valid time, between 00:00 am and 12:00 pm");


  `
  $("#edit_user, #edit_node_attributes, #edit_role_attributes").validate
    rules:
        custom: "custom"
        ip: "ip"
        uri: "uri"
        complete_uri: "complete_uri"
        printer_uri: "printer_uri"
        letterswithbasicpunc: "letterswithbasicpunc"
        alphanumeric: "alphanumeric"
        alphanumericwithdots: "alphanumericwithdots"
        lettersonly: "lettersonly"
        nowhitespace: "nowhitespace"
        abspath: "abspath"
        modefile: "modefile"
        time: "time"
        timespan: "timespan"
        time12h: "time12h"
        ipv4: "ipv4"
        ipv6: "ipv6"
        integer:
          numeric: true
          integer: true


` function clone_attribute(recipe,attribute){

    fieldset = $("#"+recipe);
    field = $("#"+attribute+"_base");
    clone = field.clone();

    if ($("#"+recipe).children("div:not(.clear)").last().val() == null) {
      size = 1;
    }else{
      size = Number($("#"+recipe).children("div:not(.clear)").last().attr("id").split("_").pop())+1;
    }



    clone.find('input').each(function() {
      $(this).val('');
      $(this).attr("value", "");
      });

    new_div_name = clone.attr("id").replace(attribute+"_base", attribute+"_"+size);
    clone.attr("id",new_div_name);


    clone.find("select, input").each(function() {
      new_id = $(this).attr("id").replace("_base_", "_"+size+"_");
      new_name = $(this).attr("name").replace("[base]", "["+size+"]");
      $(this).attr("id",new_id);
      $(this).attr("name",new_name);
      });


    clone.hide()
    clone.removeClass()


    last_input = $("div[id^="+attribute+"][class!='hidden']").last()
    if (last_input.val() == null) {
      clone.insertBefore(fieldset.children("a").last())
    }else{
      clone.insertAfter(last_input)
    }

    clone.fadeIn('slow')

    if (clone.find('.wizard').size() > 0) {
      clone.find('.wizard').each(function() {
        url = window.location.pathname;
         $(this).smartSuggest({src: url +'/search_packages.json',
                                           showImages: false,
                                           fillBox:true,
                                           boxId: '%-'+$(this).attr('id')+'-suggestions'});

      });

    }



    $(".remove").bind('click', function() {
      att = $(this).attr("attribute");
      if ($("div[id^="+att+"][class!='hidden']").size() == 1) {
         $(this).parent().parent().find("input[type!='hidden'][type!='submit'][class != 'default']").attr("value", "")
      }else{
        $(this).parent().parent().fadeOut('slow', function(){ $(this).remove();})

      };
    });
};`
