module WizardsHelper

  def wizard_search_box(field_id)
    normal_id = sanitize_to_id(field_id)
    "
    <script type='text/javascript'>

      url = window.location.pathname
      $('##{normal_id}').smartSuggest({src: url +'/search_packages.json',
                                       showImages: false,
                                       fillBox:true,
                                       boxId: '%-#{normal_id}-suggestions'});


      function append_selected (text) { }

    </script>

    "
  end

end
