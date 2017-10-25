require 'spec_helper'

describe ScJobSearcher do

  context 'searcher' do
    it 'should return sc_job records for a specific code' do      
      sc_job = Factory(:sc_job, code: 'C123')
      ScJobSearcher.new({code: 'C123'}).paginate.should == [sc_job]
      ScJobSearcher.new({code: 'D234'}).paginate.should == []
    end
  end
end