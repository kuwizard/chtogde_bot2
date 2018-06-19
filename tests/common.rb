require 'test/unit'
require 'telegram/bot'
require_relative '../app/bot_processor'
require_relative '../app/message_parser'
require_relative '../app/constants'
require_relative '../mocks/database_mock'
require_relative '../mocks/bot_processor_mock'
require_relative '../mocks/message_parser_mock'
require_relative '../mocks/game_manager_mock'
require_relative '../mocks/game_mock'
require_relative '../mocks/question_collector_mock'

module Common
  def send_message(text)
    message = Telegram::Bot::Types::Message.new(text: text, chat: @chat)
    @reply = @processor.process_message(message)
  end

  def send_button_click(button)
    @message_id = Random.new.rand(999).to_s
    msg = Telegram::Bot::Types::Message.new(chat: @chat)
    message = Telegram::Bot::Types::CallbackQuery.new(data: button.callback_data, id: @message_id, message: msg)
    @reply = @processor.process_message(message)
  end

  def change_question_to(question)
    @processor.set_test_data_file(question)
  end

  def erase_and_restore_all_games
    @processor.erase_all_games
    @processor.restore_previous_games
  end
end