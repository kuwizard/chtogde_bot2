require 'telegram/bot'
require_relative 'message_parser'
require_relative 'constants'

token = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  MessageParser.instance.init(bot)

  processor = MyBotProcessor.new(MessageParser.instance)

  bot.listen do |message|
    processor.process_message(message)
  end
end

class MyBotProcessor
  def initialize(parser)
    @parser = parser
  end

  def process_message(message)
    if message.is_a?(Telegram::Bot::Types::Message)
      message.text = message.text.gsub(Constants::BOT_NAME, '') unless message.text.nil?
    end

    response = @parser.parse_message(message)

    @parser.post(response)
  end
end

class MyBotProcessorTest

  def test_message_nil
    p = MyBotProcessor.new(MessageParserMock.new)
    p.process_message(nil)
    assert_something
  end

  def test_message_not_telegram
    p = MyBotProcessor.new(MessageParserMock.new)
    p.process_message('/start')
    assert_something
  end

  def test_message_is_telegram
    p = MyBotProcessor.new(MessageParserMock.new)
    msg = Telegram::Bot::Types::Message.new()
    msg.caption = 'Hi'
    msg.text = '/start'
    p.process_message(msg)
    assert_something
  end

  def test_message_is_telegram_text_nil
    p = MyBotProcessor.new(MessageParserMock.new)
    msg = Telegram::Bot::Types::Message.new()
    msg.caption = 'Hi'
    msg.text = nil
    p.process_message(msg)
    assert_something
  end
end

class MessageParserMock
  def parse_message(message)

  end

  def post(response)

  end
end