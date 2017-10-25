$(document).ready(function(){

  $('#sc_backend_setting_backend_code').change(function() {
    var backend_code = $(this).val();
    get_options_for_service_code(backend_code, $('#sc_backend_setting_service_code'));
  });

  $('#sc_backend_setting_service_code').change(function() {
    var service_code = $(this).val();
    get_settings($('#sc_backend_setting_backend_code').val(),service_code);
  });
  
  function get_options_for_service_code(backend_code) {
    $.ajax({
       url: '/sc_backend_settings/get_service_codes',
       dataType: "json",
       data: { backend_code: backend_code },
       success: function(data){
         $('#sc_backend_setting_service_code').empty();
         $.each(data, function (i, item) {
             $('#sc_backend_setting_service_code').append($('<option>', {
                 value: item,
                 text : item
             }));
         });
         get_settings($('#sc_backend_setting_backend_code').val(),$('#sc_backend_setting_service_code').val());
       }
    });
  };

  function get_settings(backend_code, service_code) {
    $.ajax({
       url: '/sc_backend_settings/settings',
       dataType: "script",
       data: { backend_code: backend_code, service_code: service_code }
    });
  };
});