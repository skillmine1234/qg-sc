require 'spec_helper'

describe ScBackendSettingSearcher do

  context 'searcher' do
    it 'should return matching sc_backend_setting records' do
      sc_backend_setting = Factory(:sc_backend_setting, backend_code: 'BC01', approval_status: 'A')
      ScBackendSettingSearcher.new({backend_code: 'BC01'}).paginate.should == [sc_backend_setting]
      ScBackendSettingSearcher.new({backend_code: '123'}).paginate.should == []
    
      sc_backend_setting = Factory(:sc_backend_setting, service_code: 'SC01', approval_status: 'A')
      ScBackendSettingSearcher.new({service_code: 'SC01'}).paginate.should == [sc_backend_setting]
      ScBackendSettingSearcher.new({service_code: '321'}).paginate.should == []
      
      sc_backend_setting = Factory(:sc_backend_setting, app_id: 'APP01', approval_status: 'A')
      ScBackendSettingSearcher.new({app_id: 'APP01'}).paginate.should == [sc_backend_setting]
      ScBackendSettingSearcher.new({app_id: '321'}).paginate.should == []
    end
  end
end