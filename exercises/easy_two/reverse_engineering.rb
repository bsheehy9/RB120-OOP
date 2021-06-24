class Transform
  attr_reader :string

  def initialize(string)
    @string = string
  end

  def uppercase
    string.upcase
  end

  def self.lowercase(new_string)
    new_string.downcase
  end
end

my_data = Transform.new('abc')
puts my_data.uppercase
puts Transform.lowercase('XYZ')
puts my_data.string.upcase
