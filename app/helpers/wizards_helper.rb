module WizardsHelper

  def wizard_search_box
    "
    <script type='text/javascript'>

      $('#search_box').smartSuggest({src: '/nodes/pc-pruebas/search_packages.json', showImages: false});

      selected = '<div id=selected></div>';

      $('.ss-wrap').parent().children('i').after(selected);
      alert ('lala')

      function append_selected (text) {

        $('#selected').append('<div id='+ text +'>text</div>');
      }
    </script>

    "
  end

end
