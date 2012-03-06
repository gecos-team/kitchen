# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(window).bind 'beforeunload', (e) ->
  if $("#facebox").css('display') is 'block'
    if $('div.edit_recipe', $('a.close').parent('div.popup')).get(0) == undefined
      $("#recipes ul").sortable("cancel")
      recipe_open = $('fieldset',$('#edit_node_attributes')).attr('id')
      to_node = $('#run-list ul').sortable('toArray')
      runlist = []
      for field in to_node
          runlist.push(field)
      url = window.location.pathname
      $.ajax({
        type: 'PUT',
        url: url,
        data: {for_node: runlist}
      })
      return

$(document).ready ->

  assistantIsRunning = false
  $(document).ajaxError () ->
    assistantIsRunning = false
  
  jQuery(document).bind 'close.facebox', (event) ->
    assistantIsRunning = false

  $("#run-list ul").sortable
    connectWith: ["#recipes ul", "#roles ul"],
    dropOnEmptu: true
    remove: (e, ui) ->
      if ui.item.context.classList.contains("recipe")
        regex = /(recipe)?\[?(.*::.*)\]?/
        recipe = ui.item.attr('id').match(regex)
        normalize_recipe = RegExp.$2 
        to_node = $('#run-list ul').sortable('toArray')
        runlist = []
        for field in to_node
          runlist.push(field)
        url = window.location.pathname
        if normalize_recipe == undefined
          params = {for_node: runlist}
        else
          params = {for_node: runlist, recipe_clean: normalize_recipe}
        $.ajax({
           type: 'PUT',
           url: url,
           data: params
        })
 
  $("#run-list ul").sortable
    connectWith: ["#recipes ul", "#roles ul"],
    dropOnEmpty: true
    receive: (e,ui) ->
      if assistantIsRunning is true
        ui.sender.sortable('cancel')
        return
      assistantIsRunning = true
      recipe = ui.item.text().trim()
      if ui.item.context.classList.contains("recipe")
        to_node = $('#run-list ul').sortable('toArray')
        runlist = []
        for field in to_node
          runlist.push(field)
        url = window.location.pathname
        $.ajax({
           type: 'PUT',
           url: url,
           data: {for_node: runlist}
        })
      $.getJSON ("/cookbooks/check_recipe?recipe="+recipe), (data) ->
        if data == null or data is not true
          assistantIsRunning = false
        else
          url = window.location.pathname
          $("a.close, img.close_image").unbind("click")
          ui.item.append("<span><a href="+url+"/advanced_data?recipe="+recipe+ " rel=facebox>Edit</a></span>")
          link = ui.item.find("a[rel*=facebox]")
          link.facebox()
          link.click()
          $("a.close, img.close_image").bind 'click', ->
            jQuery(document).trigger('close.facebox')
            if $('div.edit_recipe', $('a.close').parent('div.popup')).get(0) == undefined
              ui.sender.sortable('cancel')
              link.remove()
              $(this).unbind("click")
              if ui.item.context.classList.contains("recipe")
                to_node = $('#run-list ul').sortable('toArray')
                runlist = []
                for field in to_node
                  runlist.push(field)
                url = window.location.pathname
                $.ajax({
                   type: 'PUT',
                   url: url,
                   data: {for_node: runlist}
                })
            $("#facebox").remove(".popup")
            false
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
