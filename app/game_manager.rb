require 'singleton'
require_relative 'game'

class GameManager
  include Singleton

  attr_accessor :games

  def game(id)
    @games = {} if @games.nil?
    if @games.include?(id)
      @games[id]
    else
      @games[id] = Game.new
    end
  end

  def start(id)
    @games = {} if @games.nil?
    @games[id] = Game.new
    Constants::START
  end

  def stop(id)
    @games = {} if @games.nil?
    @games.delete(id) if on?(id)
    Constants::STOP
  end

  def on?(id)
    return false if @games.nil?
    @games.include?(id)
  end
end