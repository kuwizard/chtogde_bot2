class BotProcessorMock < BotProcessor
  def initialize(data = nil)
    @parser = MessageParserMock.new(data)
  end

  def set_test_data_file(name)
    @parser.game_manager.data_file = name
  end

  def erase_all_games
    @parser.game_manager.games = nil
  end

  def restore_previous_games
    @parser.game_manager.restore_previous_games
  end
end