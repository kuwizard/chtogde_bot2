class GameMock < Game
  def initialize(chat_id:, tour_name: nil, question_id: nil, asked: false, data_file: nil)
    @question_collector = QuestionCollectorMock.new(data_file)
    super(chat_id: chat_id, tour_name: tour_name, question_id: question_id, asked: asked)
  end

  def set_data_file(name)
    if !@question_collector.nil? && @question_collector.file != name
      @question_collector = QuestionCollectorMock.new(name)
    end
  end
end