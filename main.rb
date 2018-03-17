require 'telegram/bot'
require_relative 'game'

token = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
      when '/start'
        Game.instance.start
        bot.api.send_message(chat_id: message.chat.id, text: 'Ну, поехали')
      when '/stop'
        Game.instance.stop
        bot.api.send_message(chat_id: message.chat.id, text: 'Всем пока!')
      when '/next'
        if Game.instance.is_on?
          bot.api.send_message(chat_id: message.chat.id, text: Game.instance.question)
        end
      when '/answer'
        if Game.instance.is_on?
          bot.api.send_message(chat_id: message.chat.id, text: Game.instance.post_answer)
        end
      else
        if Game.instance.asked?
          message_text = message.to_s.gsub('/', '')
          check_result = Game.instance.check_suggestion(message_text)
          bot.api.send_message(chat_id: message.chat.id, text: check_result)
        end
    end
  end
end
