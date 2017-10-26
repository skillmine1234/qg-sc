ScFaultCode.seed(:fault_code) do |s|
 s.fault_code = 'ns:E400'
 s.fault_reason = 'Bad Request'
 s.fault_kind = 'T'
 s.occurs_when = 'When any request elements fails schema validation.'
 s.remedial_action = 'Fix the Request (Likely Schema Validation Error).'  
end

ScFaultCode.seed(:fault_code) do |s|
 s.fault_code = 'ns:E403'
 s.fault_reason = 'Customer / Account Access Forbidden'
 s.fault_kind = 'T'
 s.occurs_when = 'The Basic Auth User ID & Partner Code pair sent in the request, was not found in the configuration.' 
 s.remedial_action = 'The Basic Auth User ID & Partner Code are provided to you by the bank. Ensure that you are using the correct values. If you believe you are, then contact support.' 
end

ScFaultCode.seed(:fault_code) do |s|
 s.fault_code = 'ns:E404'
 s.fault_reason = 'Request Not Found'
 s.fault_kind = 'T'
 s.occurs_when = 'Request Reference Number sent in the request was not found.' 
 s.remedial_action = 'Retry with a valid Request Reference. Number.' 
end

ScFaultCode.seed(:fault_code) do |s|
 s.fault_code = 'ns:E500'
 s.fault_reason = 'Internal Server Error'
 s.fault_kind = 'T'
 s.occurs_when = 'Unhandled exception has occurred'
 s.remedial_action = 'Retry Request After 15 minutes'
end

ScFaultCode.seed(:fault_code) do |s|
 s.fault_code = 'ns:E502'
 s.fault_reason = 'Bad Gateway'
 s.fault_kind = 'T'
 s.occurs_when = 'An upstream service returned an unexpected error'
 s.remedial_action = 'Contact Support'
end
 
ScFaultCode.seed(:fault_code) do |s|
 s.fault_code = 'ns:E504'
 s.fault_reason = 'Bad Gateway'
 s.fault_kind = 'T'
 s.occurs_when = 'An upstream service times out'
 s.remedial_action = 'Retry Request After 15 minutes'
end
