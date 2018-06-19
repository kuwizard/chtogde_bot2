class MessageParserMock < MessageParser
  attr_accessor :game_manager

  def initialize(data = nil)
    @game_manager = GameManagerMock.new(data)
  end
end
