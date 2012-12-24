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

  context 'Having restoring non existed value with default' do
    it 'should have value of false' do
      val = @session.restore('non_existed', false)
      val.should == false
    end

    it 'should not have value of true' do
      val = @session.restore('non_existed', false)
      val.should_not == true
    end
  end

  context 'Checking if key and values exists' do
    it 'should have existed key' do
      @session.save('name', 1)
      key = @session.key? 'name'
      key.should == true
    end

    it 'should have non exited key' do
      key = @session.key? 'no_key'
      key.should == false
    end

    it 'should have existed value' do
      @session.save('name', 1)
      value = @session.value?('name')
      value.should == true
    end

    it 'should not have value' do
      value = @session.value? 'no_key'
      value.should == false
    end
  end

  context 'Working with expire' do
    it 'should have ttl of 5 seconds when saving' do
      @session.save('with_ttl', 1, 5)
      ttl = @session.ttl('with_ttl')
      ttl.should == 5
    end

    it 'ttl should not be set' do
      @session.save('no_ttl', 1)
      ttl = @session.ttl('no_ttl')
      ttl.should == -1
    end

    it 'should have ttl of 5 seconds when expiring' do
      @session.save('no_ttl', 1)
      @session.expire('no_ttl', 5)
      ttl = @session.ttl('no_ttl')
      ttl.should == 5
    end

    it 'save with ttl, should not exists after 5 seconds' do
      @session.save('with_ttl', 1, 5)

      sleep 5.1
      val = @session.value?('with_ttl')
      val.should == false
    end

    it 'expire with of 5 seconds, should not exists after it' do
      @session.save('no_ttl', 1)
      @session.expire('no_ttl', 5)
      sleep 5.1
      val = @session.value?('no_ttl')
      val.should == false
    end
  end

end
