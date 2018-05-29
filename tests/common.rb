require 'test/unit'
require 'telegram/bot'
require_relative '../app/bot_processor'
require_relative '../app/message_parser'
require_relative '../app/constants'
require_relative '../mocks/database_mock'

module Common
  def send_message(text)
    message = Telegram::Bot::Types::Message.new(text: text, chat: @chat)
    @processor.process_message(message)
  end

  def send_button_click(button)
    @message_id = Random.new.rand(999).to_s
    msg = Telegram::Bot::Types::Message.new(chat: @chat)
    message = Telegram::Bot::Types::CallbackQuery.new(data: button.callback_data, id: @message_id, message: msg)
    @processor.process_message(message)
  end

  def change_question_to(question)
    GameManager.instance.set_test_data_file(question)
  end
end