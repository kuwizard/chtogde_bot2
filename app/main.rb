require 'telegram/bot'
require_relative 'message_parser'
require_relative 'game_manager'
require_relative 'constants'
require_relative 'bot_processor'

token = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  GameManager.instance.restore_previous_games

  processor = BotProcessor.new(MessageParser.instance, bot)

  bot.listen do |message|
    reply = processor.process_message(message)
    processor.post_reply(reply)
  end
end

# class MyBotProcessorTest
#   def test_message_nil
#     p = BotProcessor.new(MessageParserMock.new)
#     p.process_message(nil)
#     assert_something
#   end
#
#   def test_message_not_telegram
#     p = BotProcessor.new(MessageParserMock.new)
#     p.process_message('/start')
#     assert_something
#   end
#
#   def test_message_is_telegram
#     p = BotProcessor.new(MessageParserMock.new)
#     msg = Telegram::Bot::Types::Message.new()
#     msg.caption = 'Hi'
#     msg.text = '/start'
#     p.process_message(msg)
#     assert_something
#   end
#
#   def test_message_is_telegram_text_nil
#     p = BotProcessor.new(MessageParserMock.new)
#     msg = Telegram::Bot::Types::Message.new()
#     msg.caption = 'Hi'
#     msg.text = nil
#     p.process_message(msg)
#     assert_something
#   end
# end

class BotProcessorMock < BotProcessor
  def post_reply
    # Do nothing
    sleep 0.5
  end
end