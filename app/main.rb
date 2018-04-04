require 'telegram/bot'
require_relative 'message_parser'
require_relative 'constants'

token = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  MessageParser.instance.init(bot)
  bot.listen do |message|
    if message.is_a?(Telegram::Bot::Types::Message)
      message.text = message.text.gsub(Constants::BOT_NAME, '') unless message.text.nil?
    end
    MessageParser.instance.parse_message(message)
  end
end