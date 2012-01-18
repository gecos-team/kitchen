jQuery(($) ->
  $("#printer_make").change(() ->
    make = $('select#printer_make :selected').val()
    jQuery.get('/admin/printers/models?make=' + encodeURIComponent(make), (data) ->
      $("#printer_model").html(data)
    )
    return false
  )
)
