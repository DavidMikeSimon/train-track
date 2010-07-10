module TrainCode
  DOMAIN = 9**4 # No input number this large or larger can fit in 4 digits of base 9
  OFFSETS = [0, 1527, 4872, 3456] # Added to each field modulo DOMAIN
  
  def self.encode(i)
    raise TrainCodeError.new("Cannot encode %s, it's not an Integer") unless i.is_a? Integer
    raise TrainCodeError.new("Cannot encode %u, it's larger than %u" % [i, DOMAIN]) if i >= DOMAIN
    raise TrainCodeError.new("Cannot encode %u, it's negative") if i < 0
    
    s = ""
    (0..3).each do |n|
      s += "-" if n > 0
      s += ("%04u" % ((i+OFFSETS[n]) % DOMAIN).to_s(9))
    end
    return s
  end
  
  def self.decode(s)
    parts = s.split("-")
    return parts[0].to_i(9)
  end
end

class TrainCodeError < RuntimeError
end