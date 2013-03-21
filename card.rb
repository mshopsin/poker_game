class Card

  attr_accessor :suit, :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

end

class Deck

  attr_accessor :cards
  def initialize
    @cards = all_cards.shuffle
  end

  def all_cards
    card_array = []
    suits = [:H, :D, :S, :C]
    (2..14).each do |value|
      suits.each do |suit|
        new_card = Card.new(suit, value)
        card_array << new_card
      end
    end
    card_array
  end

  def deal
    self.cards.pop
  end

end

class Player
  attr_reader :cards
  attr_accessor :game
  def initialize(cards,game)
    @cards = cards
    @game = game
  end

  def return_card(index)
    cards[index]
  end

  def show_hand
    cards.each_with_index do |card,index|
      puts "#{index}: #{card.value} #{card.suit}"
    end
  end

  def hand_rank
    hand = Hand.new(cards)
    hand.hand_rank
  end

  def replace_cards
    puts "leave blank for no cards or enter: 0 3 4"
    cards_for_removal_i = gets.chomp.split(" ").map(&:to_i)
    cards_removal = []
    cards_for_removal_i.each {|index| cards_removal << cards[index]}
    cards_removal.each {|card| cards.delete(card)}

    cards_for_removal_i.count.times{cards << game.request_new_card}
  end

end


class Hand
  attr_reader :cards
  attr_accessor :high_card
  def initialize(cards)
    @cards = cards
    @high_card = 0
  end

#@hand_value = :straight_flush
  def hand_rank


    if is_straight_flush?
      return [9, get_values.max]
    elsif of_a_kind?(4)
      return [8, of_a_kind_value(4)]
    elsif is_full_house?
      return [7, of_a_kind_value?(3)]
    elsif is_flush?
      return [6, get_values.max]
    elsif is_straight?
      return [5, get_values.max]
    elsif of_a_kind?(3)
      return [4, of_a_kind_value?(3)]
    elsif two_pair?
      return [3, two_pair_value]
    elsif of_a_kind?(2)
      return [2, of_a_kind_value?(2)]
    else
      return [1, get_values.max]
    end
  end

  def hand_value_rank
    get_one_pair_value if hand_rank == 8
  end

  #doesn't work for two pairs of two cards
  def of_a_kind_value(num)
    values = get_values #[1,2,1,3,5]
    card_val = -1
    2.upto(14) do |value|
      card_val = value if values.count(value) == num
    end
    card_val
  end

  def two_pair_value
    values = get_values #[1,2,1,3,5]
    card_val = -1
    2.upto(14) do |value|
      val = value if values.count(value) == 2
      card_val = val > card_val ? val : card_val
    end
    card_val
  end


  def is_straight_flush?
    is_flush? && is_straight?
  end

  def is_full_house?
    of_a_kind?(3) && of_a_kind?(2)
  end

  def is_flush?
    return true if 1 == get_suits.uniq.length
    false
  end

  def is_straight?
    ascending = [0,1,2,3,4]
    values = get_values.sort
    ascending.map! {|val| val + values[0]}
    return true if ascending == values
    if values.include? 14
      values[4] = 1
      values = values.sort
      ascending = [0,1,2,3,4]
      ascending.map! {|val| val + values[0]}
      return true if ascending == values
    end
    false
  end

  def of_a_kind?(num)
    values = get_values
    2.upto(14) do |value|
      return true if values.count(value) == num
    end
    false
  end

  #two pairs of two cards
  def two_pair?
    values = get_values
    count = 0
    values.uniq.each do |value|
      count += 1 if values.count(value) == 2
    end
    return count == 2
  end

  def get_suits
    cards.map{|card| card.suit }
  end

  def get_values
    cards.map{|card| card.value }
  end

end

class Game

  attr_accessor :deck, :all_players

  def initialize(num=2)
    @deck = Deck.new
    @all_players = []
    num.times{@all_players << Player.new(initial_deal,self)}
  end

  def initial_deal
    hand = []
    5.times{hand << self.deck.deal}
    return hand
  end

  def start_game
  end

  def request_new_card
    self.deck.deal
  end

  def replace_card_round
    all_players.each do |player|
      player.show_hand
      player.replace_cards
    end
  end

  def compare_scores
    best_player = nil
    best_score = [-1,-1]
    player_hash = Hash.new
    all_players.each { |player| player_hash[player] = player.hand_rank}
    sorted_players_hand_rank = player_hash.sort_by {|_key, value| value[0]}
    sorted_players_hand_rank.reverse
    max_rank = 0
    sorted_players_hand_rank.each {|player| max_rank = player[1][0] >= max_rank ? player[1][0] : max_rank }
    max_rank_count = 0
    sorted_players_hand_rank.each {|player| max_rank_count += 1 if max_rank == player[1][0] }
    max_high_card = 0
    player = nil
    tie = false
    winner = []
    0.upto(max_rank_count) do |i|

      if sorted_players_hand_rank[i][1][1] > max_high_card
        player = sorted_players_hand_rank[i][0]
        winner = [player]
        max_high_card = sorted_players_hand_rank[i][1][1]
        tie = false
      elsif sorted_players_hand_rank[i][1][1] == max_high_card
        winner += sorted_players_hand_rank[i][0]
        tie = true
      end

    end

    end
  end


end