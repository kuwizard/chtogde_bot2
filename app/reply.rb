class Reply
  attr_reader :message, :chat_id
  attr_accessor :markup, :photo, :previous_answer

  def initialize(message, chat_id, previous_answer = nil)
    @message = message
    @chat_id = chat_id
    @previous_answer = previous_answer
  end
end