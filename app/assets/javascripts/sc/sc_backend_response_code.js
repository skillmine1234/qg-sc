$(document).ready(function(){

  $('#sc_backend_response_code_fault_code').change(function() {
    var code = $('#sc_backend_response_code_fault_code').val();
    $.ajax({
       url: "/sc_fault_codes/get_fault_reason",
       data: {fault_code: code},
       success: function(data) { 
         console.log(data);
         $('#fault_reason').text('Fault Reason : ' + (data["reason"] || 'not found'));
       },
       error: function(data){
        $(parent).html('<span>Error in loading fault reason</span>');
      }
    });
    
  });

});