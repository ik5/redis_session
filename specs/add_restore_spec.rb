require 'redis_session'

describe Session::SessionClient do
  before do
   @session = Session::SessionClient.new(:prefix => 'add_test')
  end

  context 'With no values' do
    it 'should return empty hash' do
      @session.restore('name').length.should equal(0)
    end
  end
end
