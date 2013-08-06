class MassObject
  def self.set_attrs(*attributes)
    @attributes = attributes
    attributes.each do |attr|
      attr_accessor attr
    end
    attr_accessor :id

  end

  def self.attributes
    @attributes
  end

  def self.parse_all(result)
    rows = []
    result.each do |row|
      rows << self.new(row)
    end

    rows
  end

  def initialize(params = {})
    params.each do |key,val|
      if self.class.attributes.include?(key.to_sym)
        self.send("#{key}=",val)
      else
        raise "mass assignment to unregistered attribute #{key}"
      end
    end

  end
end
