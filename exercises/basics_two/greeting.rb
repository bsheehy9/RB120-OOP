class Cat
  COLOR = "purple"
  @@number_of_cats = 0
  attr_accessor :name

  def initialize(name)
    @name = name
    @@number_of_cats +=1 
  end

  def rename(new_name)
    self.name = new_name
  end

  def self.generic_greeting
    puts "Hello! I'm a cat!"
  end

  def personal_greeting
    puts "Hello! My name is #{name}!"
  end

  def greet
    puts "Hello! My name is #{name} and I'm a #{COLOR} cat!"
  end

  def identify
    self
  end

  def self.total
    puts @@number_of_cats
  end

  def to_s
    "I'm #{name}!"
  end
end

kitty = Cat.new('Sophie')
Cat.generic_greeting
kitty.personal_greeting
kitty.greet
puts kitty
