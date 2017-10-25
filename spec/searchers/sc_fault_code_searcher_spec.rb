require 'spec_helper'

describe ScFaultCodeSearcher do

  context 'searcher' do
    it 'should return sc_fault_code records for a specific backend code' do
      sc_fault_code = Factory(:sc_fault_code, fault_code: 'ns:E1234')
      ScFaultCodeSearcher.new({fault_code: 'ns:E1234'}).paginate.should == [sc_fault_code]
      ScFaultCodeSearcher.new({fault_code: '123'}).paginate.should == []
    end
    
    it 'should return sc_fault_code records for a specific response code' do
      sc_fault_code = Factory(:sc_fault_code, fault_kind: 'T')
      ScFaultCodeSearcher.new({fault_kind: 'T'}).paginate.should == [sc_fault_code]
      ScFaultCodeSearcher.new({fault_kind: '321'}).paginate.should == []
    end
  end
end