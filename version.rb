module Version
  @VERSION = "0.4.0"
  class << self
    attr_reader :VERSION
  end
end
