require "qg/sc/engine"
module Qg
  module Sc
    NAME = 'Service Center Backend'
    GROUP = 'sc-backend'
    MENU_ITEMS = [:sc_backend ,:sc_job, :sc_fault_code, :sc_backend_response_code, :sc_backend_setting, :sc_service,:esb_config]
    MODELS = ['ScBackend','ScJob','ScFaultCode','ScBackendResponseCode','ScBackendSetting','ScProxy','ScService','EsbConfig']
    TEST_MENU_ITEMS = []
    COMMON_MENU_ITEMS = [:console_data]
    RULE = :sc_proxy
  end
end
