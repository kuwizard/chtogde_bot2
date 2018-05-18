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
end