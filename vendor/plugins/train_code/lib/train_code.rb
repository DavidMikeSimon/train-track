module TrainCode
  class InputError < RuntimeError
  end
  
  class DecodeError < RuntimeError
  end
  
  DOMAIN = 9**4 # No input number >= this can fit in 4 digits of base 9; also each encoded section will be < this
  OFFSETS = [0, 1527, 4872, 3456] # Added to each field modulo DOMAIN
  
  def self.encode(i)
    raise InputError.new("Cannot encode, input is not an Integer") unless i.is_a? Integer
    raise InputError.new("Cannot encode %u, it's larger than %u" % [i, DOMAIN]) if i >= DOMAIN
    raise InputError.new("Cannot encode %u, it's negative" % i) if i < 0
    
    s = ""
    (0..3).each do |n|
      s += "-" if n > 0
      s += ("%04u" % ((i+OFFSETS[n]) % DOMAIN).to_s(9))
    end
    return s
  end
  
  def self.decode(s)
    raise InputError.new("Cannot decode input, it's not a string") unless s.is_a? String
    raise InputError.new("Cannot decode %s, invalid format" % s) unless s =~ /^\d{4}-\d{4}-\d{4}-\d{4}$/
    parts = s.gsub("9", "4").split("-") # Replace 9's with 4's, since 9's never appear in base-9 and 4 is most similar
    
    part_scores = {}
    (0..3).each do |n|
      p = parts[n].to_i(9) - OFFSETS[n]
      part_scores[p] = part_scores.has_key?(p) ? part_scores[p]+1 : 1
    end
    
    scores = part_scores.values.sort.reverse
    raise DecodeError.new("No clear result") if scores.size > 1 && scores[0] == scores[1]
    
    cand, cand_score = nil, nil
    part_scores.each do |part, score|
      if cand_score == nil or score > cand_score
        cand, cand_score = part, score
      end
    end
    return cand
  end
end