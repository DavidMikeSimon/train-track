module TrainCode
  class InputError < RuntimeError
  end
  
  DOMAIN = 9**4 # No input number >= this can fit in 4 digits of base 9; also each encoded section # will be < this
  OFFSETS = [0, 1527, 5972, 3456] # Arbitrary #'s added to each field modulo DOMAIN to form the encoded section #
  
  # Given an integer less than DOMAIN returns an encoded version in the form "####-####-####-####"
  def self.encode(i)
    raise InputError.new("Cannot encode, input is not an Integer") unless i.is_a? Integer
    raise InputError.new("Cannot encode %u, it's not smaller than %u" % [i, DOMAIN]) if i >= DOMAIN
    raise InputError.new("Cannot encode %u, it's negative" % i) if i < 0
    
    s = ""
    (0..3).each do |n|
      s += "-" if n > 0
      s += ("%04u" % ((i+OFFSETS[n]) % DOMAIN).to_s(9))
    end
    return s
  end
  
  # Given a string in the form "####-####-####-####" returns an array of integers in decreasing order of preference
  def self.decode(s)
    raise InputError.new("Cannot decode input, it's not a string") unless s.is_a? String
    raise InputError.new("Cannot decode %s, invalid format" % s) unless s =~ /^\d{4}-\d{4}-\d{4}-\d{4}$/
    parts = s.gsub("9", "4").split("-") # Replace 9's with 4's, since 9's never appear in base-9 and 4 is most similar
    
    part_scores = {}
    (0..3).each do |n|
      p = (parts[n].to_i(9) - OFFSETS[n]) % DOMAIN
      part_scores[p] = part_scores.has_key?(p) ? part_scores[p]+1 : 1
    end
    return part_scores.to_a.sort{|a,b| a[1] <=> b[1]}.reverse.map{|i| i[0]}
  end
end