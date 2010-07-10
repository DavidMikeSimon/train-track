require 'test_helper'

class TrainCodeTest < ActiveSupport::TestCase
  test "can encode a number and get it back after decoding" do
    assert_equal 1234, TrainCode.decode(TrainCode.encode(1234))
  end
end