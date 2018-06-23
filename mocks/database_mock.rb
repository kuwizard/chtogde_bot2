require_relative '../app/db'

class DatabaseMock < Database
  def initialize(data)
    if data && !data.empty?
      @data = [data]
    else
      @data = []
    end
  end

  def list_of_games(_mode)
    @data.map { |e| e[:chat_id] }
  end

  def get_question(_mode, chat_id:)
    line = @data.find { |a| a[:chat_id] == chat_id }
    line.inject({}) { |memo,(k,v)| memo[k.to_s] = v; memo} # Converting symbols to strings
  end

  def save_asked(mode, chat_id:, tour_name:, question_id:)
    if list_of_games(mode).include?(chat_id)
      delete_random(mode, chat_id: chat_id)
    end
    @data.push({ chat_id: chat_id, tour_name: tour_name, question_id: question_id, asked: 't' })
  end

  def set_asked_to_false(_mode, chat_id:)
    @data.each do |e|
      e[:asked] = 'f' if e[:chat_id] == chat_id
    end
  end

  def set_sources_state(_mode, chat_id:, sources:)
    value = sources ? 't' : 'f'
    @data.each do |e|
      e[:sources] = value if e[:chat_id] == chat_id
    end
  end

  def delete_random(_mode, chat_id:)
    @data.reject! { |e| e[:chat_id] == chat_id }
  end
end