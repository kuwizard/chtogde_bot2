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
    button_with_text('Ответ')
  end

  def next_button
    button_with_text('Следующий')
  end

  def tell_button
    button_with_text('В личку')
  end

  def horizontal_buttons_count
    @markup.inline_keyboard[0].count
  end

  def up_button
    button_with_text('⬆️')
  end

  def prev_page_button
    button_with_text('⬅️')
  end

  def next_page_button
    button_with_text('➡️')
  end

  def button_with_text(text)
    button = @markup.inline_keyboard.flatten.find { |b| b.text == text }
    raise("Cannot find tour '#{text}'") if button.nil?
    button
  end
end