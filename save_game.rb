require "strscan"

class SaveGame
  def initialize(path)
    @path = path
    @data = File.read(path).encode("UTF-8", "ISO-8859-1")
    start_tokenizer!
  end

  def start_tokenizer!
    @tokenizer = to_enum(:each_token)
    @tokenbuf = []
  end

  def each_token
    s = StringScanner.new(@data)
    raise "Not a save game" unless s.scan(/EU4txt/)
    until s.eos?
      next if s.scan(/\s+/)
      if s.scan(/"(.*?)"/)
        yield([:value, s[1]])
      elsif s.scan(/(\d+)\.(\d+)\.(\d+)/)
        yield([:value, [:date, s[1], s[2], s[3]]])
      elsif s.scan(/(-?\d+\.\d+)/)
        yield([:value, s[0].to_f])
      elsif s.scan(/\b(yes|no)\b/)
        yield([:value, $1 == "yes"])
      elsif s.scan(/(-?\d+)/)
        yield([:value, s[0].to_i])
      elsif s.scan(/[a-zA-Z_\-][a-zA-Z_.0-9\-]*/)
        yield([:value, s[0].to_sym])
      elsif s.scan(/\{/)
        yield([:start])
      elsif s.scan(/\}/)
        yield([:end])
      elsif s.scan(/\=/)
        yield([:eq])
      else
        raise "Parse error at position #{s.pos}}"
      end
    end
  end

  def fetch_next_token
    @tokenizer.next
  rescue StopIteration
    nil
  end

  def token(i)
    return @tokenbuf[i] if @tokenbuf[i]
    @tokenbuf << fetch_next_token while i >= @tokenbuf.size
    @tokenbuf[i]
  end

  def token_type(i)
    (token(i) || [])[0]
  end

  def shift(n=1)
    n.times{ @tokenbuf.shift }
  end

  def eof?
    !token(0)
  end

  def parse_error!
raise "Parse error: #{token(0).inspect} #{token(1).inspect} #{token(2).inspect}..."
  end

  def parse_value
    if token_type(0) == :value and token_type(1) == :eq
      key = token(0)[1]
      shift(2)
      val = parse_value
      {key => val}
    elsif token_type(0) == :value
      val = token(0)[1]
      shift
      val
    elsif token_type(0) == :start
      shift
      val = []
      while !eof? and token_type(0) != :end
        val << parse_value
      end
      shift
      val
    else
      parse_error!
    end
  end

  def parse
    until eof?
      yield parse_value
    end
  end
end
