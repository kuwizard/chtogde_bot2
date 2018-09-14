require 'test/unit'
require 'telegram/bot'
require_relative '../app/bot_processor'
require_relative '../app/message_parser'
require_relative '../app/misc/constants'
require_relative '../mocks/database_mock'
require_relative '../mocks/bot_processor_mock'
require_relative '../mocks/message_parser_mock'
require_relative '../mocks/game_manager_mock'
require_relative '../mocks/game_mock'
require_relative '../mocks/question_collector_mock'
require_relative 'data/users'

module Common
  def send_message(text)
    message = Telegram::Bot::Types::Message.new(text: text, chat: @chat)
    @reply = @processor.process_message(message)
  end

  def send_button_click(button)
    @message_id = Random.new.rand(999).to_s
    msg = Telegram::Bot::Types::Message.new(chat: @chat)
    message = Telegram::Bot::Types::CallbackQuery.new(data: button.callback_data, id: @message_id, message: msg, from: Users::TEST_USER)
    @reply = @processor.process_message(message)
  end

  def change_question_to(question)
    @processor.set_test_data_file(question)
  end

  def erase_and_restore_all_games
    @processor.erase_all_games
    @processor.restore_previous_games
  end

  def add_bot_to_chat
    message = Telegram::Bot::Types::Message.new(chat: @chat, from: Users::TEST_USER, new_chat_members: [Users::BOT])
    @reply = @processor.process_message(message)
  end

  def remove_bot_from_chat
    message = Telegram::Bot::Types::Message.new(chat: @chat, from: Users::TEST_USER, left_chat_member: Users::BOT)
    @reply = @processor.process_message(message)
  end
end