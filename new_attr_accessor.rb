class Cat


  def self.new_attr_accessor(*attrs)

    attrs.each do |attr|
      #make a getter
      define_method(attr) do
        self.instance_variable_get("@#{attr}")
      end
      #make a setter
      define_method("#{attr}=") do |value|
        self.instance_variable_set("@#{attr}", value)
      end

    end

  end

  def dooo
    self.send("name=", 5)
  end


  new_attr_accessor :name, :color
end

cat = Cat.new
cat.name = "Sally"
cat.color = "brown"
p cat.name
p cat.color
cat.dooo
p cat.name