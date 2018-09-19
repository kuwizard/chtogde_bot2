require_relative '../misc/enums'

class Reply
  attr_reader :message, :chat_id, :previous_answer
  attr_accessor :markup, :photo, :callback_id, :type

  def initialize(message: nil, chat_id:, previous_answer: nil, callback_id: nil, markup: nil, type: nil)
    @message = message
    @chat_id = chat_id
    @previous_answer = previous_answer
    @callback_id = callback_id
    @markup = markup
    @type = type || ReplyType::NEW
  end

  def answer_button
    @markup.inline_keyboard[0].find { |button| button.callback_data.include?('answer') }
  end

  def next_button
    @markup.inline_keyboard[0].find { |button| button.callback_data.include?('next_question') }
  end

  def tell_button
    @markup.inline_keyboard[0].find { |button| button.callback_data.include?('tell') }
  end

  def buttons_count
    @markup.inline_keyboard[0].count
  end
end