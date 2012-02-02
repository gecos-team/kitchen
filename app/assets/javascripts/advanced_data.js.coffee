$(document).ready ->
  $('#facebox_overlay').unbind("click")
  $(".default").bind 'change', ->
    inputs = $(this).parents("form").find("input[type!='hidden'][type!='submit'][class != 'default']")
    if $(this).attr("class") != "default lock"
       $(this).addClass("lock")
       for input in inputs
         $(input).attr("disabled", "disabled")
 #         $(input).attr("value", $(input).attr("default"))
    else
      $(this).removeClass("lock")
      for input in inputs
        $(input).removeAttr("disabled")
    false

`
  var on_field_change = function(event) {

    var current_elem = this;
    var id = $(this).attr('id');
    var s_class = 'dependent' + id;
    var context = $(this).parents('form').get(0);
    var value = $(this).val();

    // Dependent fields info are stored in a hidden tag.
    // For each field-info-struct we got the dependent field id,
    // and the validator name the current field must pass.
    // If the current field pass the validator then the dependent
    // field has to be required.
    $('ul.' + s_class + ' li', context).each(function(index, elem) {

      var field = $('span.field', elem).html();
      var validator = $('span.validator', elem).html();
      var f_validator = jQuery.validator.methods[validator];

      if (typeof(f_validator) == 'function') {

        var valid = f_validator(value, current_elem);
        var $field = $('[id$="' + field + '"]');
        if (valid) {
          $field
            .addClass('required')
            .removeClass('notrequired');
        } else {
          $field
            .addClass('notrequired')
            .removeClass('required');
        }
      }
    });
  };

  // Process items with dependent fields
  $('.has_dependents').each(function(index, elem) {
    $(elem).unbind().change(on_field_change);
  });
`
