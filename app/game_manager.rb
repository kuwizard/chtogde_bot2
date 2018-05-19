require 'singleton'
require_relative 'game'
require_relative 'db'

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
      @db.delete_random(:random, chat_id: id)
    end
    Constants::STOP
  end

  def on?(id)
    return false if @games.nil?
    @games.include?(id)
  end

  def restore_previous_games(db = nil)
    if db.nil?
      @db = Database.new
    else
      @db = db
    end
    @games = {} if @games.nil?
    games_of_random_mode = @db.list_of_games(:random)
    games_of_random_mode.each do |chat_id|
      chat_id = chat_id.to_i
      question = @db.get_question(:random, chat_id: chat_id)
      @games[chat_id] = Game.new(chat_id: chat_id, tour_name: question['tour_name'], question_id: question['question_id'], asked: question['asked'])
    end
  end

  def post_answer_to_game(id, mode:)
    unless mode == :i_am_a_cheater
      @db.set_asked_to_false(:random, chat_id: @chat_id)
    end
    game(id).post_answer(mode: mode)
  end
end