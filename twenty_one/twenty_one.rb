require 'pry'

module Hand
  def show_hand
    puts "----#{name}'s hand----"
    hand.each { |card| puts card }
    puts "(Total: #{total})"
    puts ""
  end

  def total
    total = 0
    hand.each { |card| total += card.value }
    # normalize aces
    hand.map(&:face).count('A').times do
      break if total <= 21
      total -= 10
    end
    total
  end

  def busted?
    total > 21
  end

  def blackjack?
    total == 21
  end
end

class Participant
  include Hand

  attr_accessor :name, :hand

  def initialize
    @hand = []
  end

  def add_card(card)
    @hand << card
  end

  def busted_or_blackjack?
    busted? || blackjack?
  end
end

class Player < Participant
  def set_name
    puts "What is your name?"
    self.name = gets.chomp
  end

  def show_flop
    show_hand
  end
end

class Dealer < Participant
  DEALER_NAMES = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5']

  def initialize
    super
    @name = DEALER_NAMES.sample
  end

  def show_flop
    puts "---- #{name}'s Hand ----"
    puts hand.first
    puts " ?? "
    puts ""
  end
end

class Card
  SUITS = ['C', 'S', 'H', 'D']
  FACE_CARDS = ['J', 'Q', 'K', 'A']
  FACES = FACE_CARDS + (2..10).to_a.map(&:to_s)

  attr_reader :face

  def initialize(suit, face)
    @suit = suit
    @face = face
  end

  def to_s
    "The #{face_name} of #{suit}"
  end

  def face_name
    case @face
    when 'J' then 'Jack'
    when 'Q' then 'Queen'
    when 'K' then 'King'
    when 'A' then 'Ace'
    else
      @face
    end
  end

  def suit
    case @suit
    when 'H' then 'Hearts'
    when 'D' then 'Diamonds'
    when 'S' then 'Spades'
    when 'C' then 'Clubs'
    end
  end

  def value
    if face == 'A'
      11
    elsif FACE_CARDS.include?(face)
      10
    else
      face.to_i
    end
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    Card::SUITS.each do |suit|
      Card::FACES.each do |face|
        @cards << Card.new(suit, face)
      end
    end
  end

  def deal_one
    cards.delete_at(rand(cards.length))
  end
end

class TwentyOne
  attr_reader :player, :dealer
  attr_accessor :deck

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def deal_cards
    2.times do
      player.add_card(deck.deal_one)
      dealer.add_card(deck.deal_one)
    end
  end

  def display_welcome_message
    puts "Welcome to Twenty One!"
  end

  def display_goodbye_message
    puts "Thanks for playing! Goodbye."
  end

  def begin_game
    display_welcome_message
    player.set_name
  end

  def show_hands
    player.show_flop
    dealer.show_flop
  end

  def player_decision
    decision = nil
    loop do
      puts "Would you like to (h)it or (s)tay?"
      decision = gets.chomp
      break if ['h', 's'].include?(decision)
    end
    decision
  end

  def player_turn
    loop do
      break if player.busted_or_blackjack?
      player_decision == 'h' ? player.add_card(deck.deal_one) : break
      show_hands
    end
  end

  def computer_turn
    loop do
      break if dealer.busted_or_blackjack? || dealer.total >= 17
      dealer.add_card(deck.deal_one)
      show_hands
    end
  end

  def show_result
    puts "This is the result."
  end

  def play_again?
    decision = nil
    loop do
      puts "Would you like to play again? (y/n)"
      decision = gets.chomp
      break if ['y', 'n'].include?(decision)
      puts "Sorry, that is not a valid answer."
    end
    decision == 'y'
  end

  def reset
    self.deck = Deck.new
    player.hand = []
    dealer.hand = []
  end

  def main_game
    deal_cards
    show_hands
    player_turn
    computer_turn unless player.busted_or_blackjack?
    show_result
  end

  def start
    begin_game
    loop do
      main_game
      break unless play_again?
      reset
    end
    display_goodbye_message
  end
end

game = TwentyOne.new
game.start
