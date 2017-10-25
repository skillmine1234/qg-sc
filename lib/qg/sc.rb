require "qg/sc/engine"
module Qg
  module Sc
    NAME = 'Service Center Backend'
    GROUP = 'sc-backend'
    MENU_ITEMS = [:sc_backend ,:sc_job, :sc_fault_code, :sc_backend_response_code, :sc_backend_setting]
    MODELS = ['ScBackend','ScJob','ScFaultCode','ScBackendResponseCode','ScBackendSetting']
    TEST_MENU_ITEMS = []
  end
end
