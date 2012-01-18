# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

  $("#run-list ul").sortable
    connectWith: ["#recipes ul", "#roles ul"],
    dropOnEmpty: true
    receive: (e,ui) ->
      recipe = ui.item.text().trim()
      $.getJSON ("/cookbooks/check_recipe?recipe="+recipe), (data) ->
        if data is true
          url = window.location.pathname
          ui.item.append("<span><a href="+url+"/advanced_data?recipe="+recipe+" rel=facebox>Edit</a></span>")
          link = ui.item.find("a[rel*=facebox]")
          link.facebox()
          link.click()
          $(".close_image").bind 'click', ->
            jQuery(document).trigger('close.facebox')
            ui.sender.sortable('cancel')
            link.remove()
            $(this).unbind("click")
            $("#facebox").remove(".popup")
            false
          $('#facebox_overlay').unbind("click")
          $("#default_attributes").live 'change', ->
            inputs = $(this).next("form").find("input[type!='hidden'][type!='submit']")
            if $(this).attr("class") == "unlock"
               inputs.attr("disabled", "disabled")
               $(this).removeClass("unlock")
            else
              inputs.removeAttr("disabled")
              $(this).addClass("unlock")
              false
          false

          # $(document).bind 'afterClose.facebox', ->
          #   $.getJSON (url+"/check_data?recipe="+recipe), (data_check) ->
          #     if data_check is true
          #       ui.sender.sortable('cancel')
          #       link.remove()

      # recipe = ui.item.text().trim()
      #   $.getJSON ("/nodes/check_recipe?recipe="+recipe), (data) ->
      #     if data is "true"
      #       alert data
      #
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
      ui.item.find("a[rel*=facebox]").parent().remove()
      # url = window.location.pathname
      # recipe = ui.item.text().trim()
      # $.post (url+"/clean_data?recipe="+recipe)

  $("#run-list ul").disableSelection()
  $("#run-list ul").disableSelection()
  $("#run-list ul").disableSelection()

  $("#tabs").tabs()

  $("form#edit_node, form.edit_role").submit (event) ->
    form = $(this)
    to_node = $('#run-list ul').sortable('toArray')
    for field in to_node
      form.append('<input type="hidden" name="for_node[]" value="' + field + '"/>')



  $(".toggle .ui-icon").click () ->
    $(this).toggleClass("ui-icon-triangle-1-e ui-icon-triangle-1-s")
    $(this).parents().next('.toggable').slideToggle("fast")

  # $("input.disabled").live 'click', ->
  #   $(this).removeAttr("disabled")

  $("#tabs-2").children("ul").treeview
      collapsed: true


  $("table.tablesorter").dataTable
    "bJQueryUI": true
    "bLengthChange": false
    "iDisplayLength": 20
    "sPaginationType": "full_numbers"


  $("table.tablesorterdom").dataTable
    "bJQueryUI": true
    "bLengthChange": false
    "iDisplayLength": 20
    "sPaginationType": "full_numbers"
    "aaSorting": [ [0,'asc'], [1,'asc'] ]
    "aoColumns": [
      { "sSortDataType": "dom-checkbox" },
      null,
      null,
      null,
      null,
      ]


  $("a[rel*=facebox]").facebox()
  $('#facebox_overlay').unbind("click")

  $('table.tree').treeTable
    expandable: true
  $('span.expander').click ->
    $('tr#' + $(this).attr('toggle')).toggleBranch()