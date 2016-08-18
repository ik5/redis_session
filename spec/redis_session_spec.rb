require 'spec_helper'

describe RedisSession do
  it 'has a version number' do
    expect(RedisSession::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
