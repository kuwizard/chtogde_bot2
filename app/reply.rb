class Reply
  attr_reader :message, :chat_id, :previous_answer
  attr_accessor :markup, :photo, :callback_id

  def initialize(message, chat_id, previous_answer: nil, callback_id: nil)
    @message = message
    @chat_id = chat_id
    @previous_answer = previous_answer
    @callback_id = callback_id
  end

  def answer_button
    @markup.inline_keyboard[0][0]
  end

  def next_button
    @markup.inline_keyboard[0][1]
  end
end