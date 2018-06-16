require 'singleton'
require_relative 'game'
require_relative 'db'

class GameManager
  include Singleton

  attr_accessor :games

  def game(id)
    @games = {} if @games.nil?
    if @games.include?(id)
      @games[id].set_data_file(@data_file) if @data_file
      @games[id]
    end
  end

  def start(id)
    @games = {} if @games.nil?
    @games[id] = Game.new(chat_id: id, data_file: @data_file) unless @games.include?(id)
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
      @games[chat_id] = Game.new(chat_id: chat_id,
                                 tour_name: question['tour_name'],
                                 question_id: question['question_id'],
                                 asked: question['asked'],
                                 data_file: @data_file)
    end
  end

  def post_answer_to_game(id, mode: :normal)
    unless mode == :i_am_a_cheater
      @db.set_asked_to_false(:random, chat_id: id)
    end
    game(id).post_answer(mode: mode)
  end

  def check_suggestion_in_game(id, message)
    correct, text_to_return = game(id).check_suggestion(message)
    @db.set_asked_to_false(:random, chat_id: id) if correct
    text_to_return
  end

  def new_question_for_game(id)
    new_question = game(id).new_question
    if @db
      @db.save_asked(:random, chat_id: id, tour_name: new_question.tour_name, question_id: new_question.id)
    end
    new_question.text
  end

  def set_test_data_file(name)
    @data_file = name
  end

  # TODO: Switch GameManager to object rather than Singleton and remove this destructive method
  def erase_all_games
    @games = nil
  end
end