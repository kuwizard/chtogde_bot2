require 'test/unit'
require 'telegram/bot'
require_relative '../app/bot_processor'
require_relative '../app/message_parser'
require_relative '../mocks/database_mock'

# encoding: utf-8
class RealChgkDBTest < Test::Unit::TestCase

  def test_first
    processor = BotProcessor.new(MessageParser.instance)
    chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123')
    message = Telegram::Bot::Types::Message.new(text: '/start', chat: chat)
    processor.process_message(message)
    message = Telegram::Bot::Types::Message.new(text: '/next', chat: chat)
    reply = processor.process_message(message)
    assert_match(/\*Вопрос\*: .*/, reply.message, '')
  end

  def test_repeat
    db = DatabaseMock.new({ chat_id: 123, question_id: '1', tour_name: 'okno13.2', asked: 't'})
    GameManager.instance.restore_previous_games(db)
    processor = BotProcessor.new(MessageParser.instance)
    chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123')
    message = Telegram::Bot::Types::Message.new(text: '/repeat', chat: chat)
    reply = processor.process_message(message)
    assert_equal('*Вопрос*: Предки домашних кур, бАнкивские джунглевые куры, куда меньше своих потомков и поэтому опровергают известную пренебрежительную поговорку. А каким образом?', reply.message, 'Incorrect question')
  end
end