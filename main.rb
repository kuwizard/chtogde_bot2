require 'telegram/bot'
require_relative 'message_parser'
require_relative 'constants'

token = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    message.text = message.text.gsub(Constants::BOT_NAME, '') unless message.text.nil?
    MessageParser.instance.parse_message(message, bot)
  end
end
