class GameManagerMock < GameManager
  attr_accessor :games, :data_file

  def initialize(data = {})
    @db = DatabaseMock.new(data)
    restore_previous_games
  end

  def game(id)
    @games = {} if @games.nil?
    if @games.include?(id)
      @games[id].set_data_file(@data_file) if @data_file
    end
    super
  end

  def start(id)
    @games = {} if @games.nil?
    @games[id] = GameMock.new(chat_id: id, data_file: @data_file) unless @games.include?(id)
    Constants::START
  end

  def restore_previous_games
    @games = {} if @games.nil?
    games_of_random_mode = @db.list_of_games(:random)
    games_of_random_mode.each do |chat_id|
      chat_id = chat_id.to_i
      question = @db.question(:random, chat_id: chat_id)
      sources = @db.sources(chat_id: chat_id)
      @games[chat_id] = GameMock.new(chat_id: chat_id,
                                 tour_name: question['tour_name'],
                                 question_id: question['question_id'],
                                 asked: question['asked'],
                                 sources: sources,
                                 data_file: @data_file)
    end
  end
end