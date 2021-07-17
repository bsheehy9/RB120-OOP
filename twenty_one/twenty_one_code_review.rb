module Clearable
  def clear
    system 'clear'
  end

  def hit_enter
    puts "<hit enter>"
    $stdin.gets
  end
end

class Card
  SUITS = ['Clubs', 'Spades', 'Hearts', 'Diamonds']
  FACES = (2..10).to_a.map(&:to_s) + ['J', 'Q', 'K', 'A']

  attr_reader :face, :suit

  def initialize(suit, face)
    @suit = suit
    @face = face
  end

  def to_s
    "The #{face} of #{suit}"
  end

  def value
    if face == 'A'
      11
    elsif face.to_i == 0
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

module Hand
  def show_hand
    puts "----#{name}'s Hand----"
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
  include Clearable, Hand

  attr_accessor :name, :hand

  def initialize
    @hand = []
  end

  def add_card(card)
    hand << card
  end

  def hit(card)
    clear
    puts "#{name} hit!"
    puts ""
    add_card(card)
  end

  def busted_or_blackjack?
    busted? || blackjack?
  end

  def display_busted_blackjack
    if busted?
      puts "#{name} busted!"
      puts ""
    elsif blackjack?
      puts "#{name} got 21!"
      puts ""
    end
  end
end

class Player < Participant
  include Clearable

  def set_name
    puts "What is your name?"
    self.name = gets.chomp
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

class TwentyOne
  include Clearable

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

  def display_goodbye_message
    puts "Thanks for playing! Goodbye."
  end

  def begin_game
    clear
    puts "Welcome to Twenty One!"
    player.set_name
    clear
  end

  def dealer_turn_display
    clear
    puts "#{dealer.name}'s turn!"
    puts ""
    show_hands(show_dealer: true)
    hit_enter
  end

  def show_hands(show_dealer: false)
    player.show_hand
    show_dealer ? dealer.show_hand : dealer.show_flop
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
      player_decision == 'h' ? player.hit(deck.deal_one) : break
      show_hands
    end
  end

  def computer_turn
    display_dealer_turn
    loop do
      break if dealer.busted_or_blackjack? || dealer.total >= 17
      dealer.hit(deck.deal_one)
      show_hands(show_dealer: true)
      hit_enter
    end
  end

  def evaluate_winner
    if player.total > dealer.total
      "#{player.name} wins!"
    elsif dealer.total > player.total
      "#{dealer.name} wins!"
    else
      "It's a push!"
    end
  end

  def show_result
    clear
    show_hands(show_dealer: true)
    if player.busted_or_blackjack?
      player.display_busted_blackjack
    elsif dealer.busted_or_blackjack?
      dealer.display_busted_blackjack
    else
      puts evaluate_winner
      puts ""
    end
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
    clear
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
