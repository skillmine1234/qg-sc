require 'spec_helper'

describe ScBackendResponseCodeSearcher do

  context 'searcher' do
    it 'should return sc_backend_response_code records for a specific backend code' do
      sc_backend = Factory(:sc_backend, approval_status: 'A')
      sc_backend_response_code = Factory(:sc_backend_response_code, sc_backend_code: sc_backend.code, approval_status: 'A')
      ScBackendResponseCodeSearcher.new({sc_backend_code: sc_backend.code}).paginate.should == [sc_backend_response_code]
      ScBackendResponseCodeSearcher.new({sc_backend_code: '123'}).paginate.should == []
    end
    
    it 'should return sc_backend_response_code records for a specific response code' do
      sc_backend = Factory(:sc_backend, approval_status: 'A')
      sc_backend_response_code = Factory(:sc_backend_response_code, response_code: '123', approval_status: 'A')
      ScBackendResponseCodeSearcher.new({response_code: '123'}).paginate.should == [sc_backend_response_code]
      ScBackendResponseCodeSearcher.new({response_code: '321'}).paginate.should == []
    end
  end
end