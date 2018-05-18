require 'telegram/bot'
require_relative 'message_parser'
require_relative 'game_manager'
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
