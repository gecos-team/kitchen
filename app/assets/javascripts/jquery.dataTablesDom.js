$.fn.dataTableExt.afnSortData['dom-text'] = function  ( oSettings, iColumn )
{
  var aData = [];
  $( 'td:eq('+iColumn+') input', oSettings.oApi._fnGetTrNodes(oSettings) ).each( function () {
    aData.push( this.value );
  } );
  return aData;
}

/* Create an array with the values of all the select options in a column */
$.fn.dataTableExt.afnSortData['dom-select'] = function  ( oSettings, iColumn )
{
  var aData = [];
  $( 'td:eq('+iColumn+') select', oSettings.oApi._fnGetTrNodes(oSettings) ).each( function () {
    aData.push( $(this).val() );
  } );
  return aData;
}

/* Create an array with the values of all the checkboxes in a column */
$.fn.dataTableExt.afnSortData['dom-checkbox'] = function  ( oSettings, iColumn )
{
  var aData = [];
  $( 'td:eq('+iColumn+') input[type=checkbox]', oSettings.oApi._fnGetTrNodes(oSettings) ).each( function () {
    aData.push( this.checked==true ? "0" : "1" );
  } );
  return aData;
}