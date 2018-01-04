require 'test_helper'

describe Lockme::Room do
  describe "all" do
    it 'performs a GET request to /rooms' do
      Lockme::SignedRequest.stub(:perform, ->(method, path) { return [method, path] }) do
        assert_equal(Lockme::Room.all, ["get", "/rooms"])
      end
    end
  end
end
