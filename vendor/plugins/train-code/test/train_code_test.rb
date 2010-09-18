require 'test_helper'

class TrainCodeTest < ActiveSupport::TestCase
  def offset_code_section(sec, offset)
    "%04u" % sec.to_i(9).+(offset).%(TrainCode::DOMAIN).to_s(9)
  end
  
  test "can encode a number and get it back after decoding" do
    assert_equal [1234], TrainCode.decode(TrainCode.encode(1234))
  end
  
  test "cannot encode a number larger than or equal to TrainCode.DOMAIN" do
    assert_raise TrainCode::InputError do TrainCode.encode(TrainCode::DOMAIN) end
    assert_raise TrainCode::InputError do TrainCode.encode(TrainCode::DOMAIN + 55) end
    assert_nothing_raised do TrainCode.encode(TrainCode::DOMAIN-1) end
  end
  
  test "cannot encode negative numbers" do
    assert_raise TrainCode::InputError do TrainCode.encode(-1) end
    assert_nothing_raised do TrainCode.encode(0) end
  end
  
  test "cannot encode non-integers" do
    assert_raise TrainCode::InputError do TrainCode.encode(3.5) end
    assert_raise TrainCode::InputError do TrainCode.encode("45") end
  end
  
  test "encoded number is 16 digits separated by dashes into 4 4-digit sections" do
    assert_match /^\d{4}-\d{4}-\d{4}-\d{4}$/, TrainCode.encode(1234)
    assert_match /^\d{4}-\d{4}-\d{4}-\d{4}$/, TrainCode.encode(1) # Check 0 padding
  end
  
  test "encoded numbers are strings" do
    assert_kind_of String, TrainCode.encode(1234)
  end
  
  test "encoded number's first section is the input number in base 9" do
    assert_match /^#{1234.to_s(9)}-/, TrainCode.encode(1234)
  end
  
  test "the number 9 does not occur anywhere in an encoded number" do
    [1234, 5678, 1525, 1999].each do |i|
      assert_no_match /9/, TrainCode.encode(i)
    end
  end
  
  test "encoded number's sections other than the first are not equal to the input number in base 9" do
    parts = TrainCode.encode(1234).split("-")
    parts.shift
    parts.each do |p|
      assert_not_equal 1234, p.to_i(9)
    end
  end
  
  test "encoded number's sections are all different from each other" do
    parts = TrainCode.encode(1234).split("-")
    parts.each do |p|
      assert_equal 1, parts.count(p)
    end
  end
  
  test "cannot pass a non-string to decode" do
    assert_raise TrainCode::InputError do TrainCode.decode(35) end
  end
  
  test "cannot pass a string not in the right format to decode" do
    assert_raise TrainCode::InputError do TrainCode.decode("1234-5678-1234") end
  end
  
  test "9's are considered 4's for the purposes of decoding" do
    c = TrainCode.encode(4)
    assert_match /^0004/, c
    assert_equal [4], TrainCode.decode(c.gsub("4", "9"))
  end
  
  test "the first of two decoded results will be correct after changing any single code section" do
    c = TrainCode.encode(1234)
    (0..3).each do |n|
      parts = c.split('-')
      parts[n] = offset_code_section(parts[n], 15)
      changed_c = parts.join('-')
      a = TrainCode.decode(changed_c)
      assert_equal 2, a.size
      assert_equal 1234, a[0]
      assert_not_equal 1234, a[1]
    end
  end
  
  test "the first of three decoded results will be correct after changing any two code sections by different offsets" do
    c = TrainCode.encode(1234)
    [[0,1], [0,2], [0,3], [1,2], [1,3], [2,3]].each do |a, b|
      parts = c.split('-')
      parts[a] = offset_code_section(parts[a], 38)
      parts[b] = offset_code_section(parts[b], 45)
      changed_c = parts.join('-')
      a = TrainCode.decode(changed_c)
      assert_equal 3, a.size
      assert_equal 1234, a[0]
      assert_not_equal 1234, a[1]
      assert_not_equal 1234, a[2]
    end
  end
  
  test "after changing 3 code sections by different offsets, 4 different results are returned, 1 of which is right" do
    c = TrainCode.encode(1234)
    (0..3).each do |n|
      parts = c.split('-')
      (0..3).each do |m|
        parts[m] = offset_code_section(parts[m], (m+1)*57) unless n == m
      end
      changed_c = parts.join('-')
      a = TrainCode.decode(changed_c)
      assert_equal 4, a.size
      assert_equal 1, a.count(1234)
    end
  end
  
  test "get an array of 4 different wrong results after changing all four code sections by different offsets" do
    c = TrainCode.encode(1234)
    parts = c.split('-')
    (0..3).each do |m|
      parts[m] = offset_code_section(parts[m], (m+1)*12)
    end
    changed_c = parts.join('-')
    a = TrainCode.decode(changed_c)
    assert_equal 4, a.size
    assert_equal 0, a.count(1234)
  end
end