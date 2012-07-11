require 'redis_session'

describe Session::SessionClient do
  before do
   @session = Session::SessionClient.new(:prefix => 'add_test')
  end
  after do
    @session.remove('name')
  end

  context 'With no values' do
    it 'should return empty hash' do
      @session.restore('name').length.should equal(0)
    end
  end

  context 'With saving values' do
    it 'should restore the "name" with "session"' do
      @session.save('name', { 'name' => 'session'})
      restored = @session.restore('name')
      restored.class.should equal Hash and restored.should eq({'name' => 'session'})
    end
  end
end
