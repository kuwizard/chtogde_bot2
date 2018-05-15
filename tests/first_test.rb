require 'test/unit'
require 'telegram/bot'
require_relative '../app/bot_processor'
require_relative '../app/message_parser'

# encoding: utf-8

class Start < Test::Unit::TestCase
  def setup
    GameManager.instance.restore_previous_games
  end

  def test_first
    processor = BotProcessor.new(MessageParser.instance)
    chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123')
    message = Telegram::Bot::Types::Message.new(text: '/start', chat: chat)
    processor.process_message(message)
    message = Telegram::Bot::Types::Message.new(text: '/next', chat: chat)
    reply = processor.process_message(message)
    assert_match(/\*Вопрос\*: .*/, reply.message, '')
  end
end