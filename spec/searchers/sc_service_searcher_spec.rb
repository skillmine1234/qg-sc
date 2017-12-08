require 'spec_helper'

describe ScServiceSearcher do

  context 'searcher' do
    it 'should return matching sc_service records' do
      sc_service = Factory(:sc_service, code: 'BC01', approval_status: 'A')
      ScServiceSearcher.new({code: 'BC01'}).paginate.should == [sc_service]
      ScServiceSearcher.new({code: '123'}).paginate.should == []
    end
  end
end