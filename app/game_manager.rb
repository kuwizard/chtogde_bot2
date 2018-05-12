require 'singleton'
require_relative 'game'

class GameManager
  include Singleton

  attr_accessor :games

  def game(id)
    @games = {} if @games.nil?
    if @games.include?(id)
      @games[id]
    end
  end

  def start(id)
    @games = {} if @games.nil?
    @games[id] = Game.new(chat_id: id) unless @games.include?(id)
    Constants::START
  end

  def stop(id)
    @games = {} if @games.nil?
    if on?(id)
      @games.delete(id)
      Database.instance.delete_random(:random, chat_id: id)
    end
    Constants::STOP
  end

  def on?(id)
    return false if @games.nil?
    @games.include?(id)
  end

  def restore_previous_games
    Database.instance.init
    @games = {} if @games.nil?
    games_of_random_mode = Database.instance.list_of_games(:random)
    games_of_random_mode.each do |chat_id|
      chat_id = chat_id.to_i
      question = Database.instance.get_question(:random, chat_id: chat_id)
      @games[chat_id] = Game.new(chat_id: chat_id, tour_name: question['tour_name'], question_id: question['question_id'], asked: question['asked'])
    end
  end
end