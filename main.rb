require 'telegram/bot'
require_relative 'game'
require_relative 'constants'

token = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    message.text = message.text.gsub(Constants::BOT_NAME, '') unless message.text.nil?
    case message.text
      when '/start'
        Game.instance.start
        bot.api.send_message(chat_id: message.chat.id, text: Constants::START)
      when '/stop'
        Game.instance.stop
        bot.api.send_message(chat_id: message.chat.id, text: Constants::STOP)
      when '/help'
        bot.api.send_message(chat_id: message.chat.id, text: Constants::HELP)
      when '/next'
        if Game.instance.is_on?
          if Game.instance.asked?
            bot.api.send_message(chat_id: message.chat.id, text: Game.instance.post_answer(to_last: true), parse_mode: 'Markdown')
          end
          bot.api.send_message(chat_id: message.chat.id, text: Game.instance.question, parse_mode: 'Markdown')
        else
          bot.api.send_message(chat_id: message.chat.id, text: Constants::NOT_STARTED)
        end
      when '/answer'
        if Game.instance.is_on?
          bot.api.send_message(chat_id: message.chat.id, text: Game.instance.post_answer, parse_mode: 'Markdown')
        else
          bot.api.send_message(chat_id: message.chat.id, text: Constants::NOT_STARTED)
        end
      when '/tellme'
        if Game.instance.asked?
          bot.api.send_message(chat_id: message.from.id, text: Game.instance.post_answer(finished: false), parse_mode: 'Markdown')
        else
          bot.api.send_message(chat_id: message.chat.id, text: Constants::NOT_STARTED)
        end
      else
        if Game.instance.is_on?
          if Game.instance.asked?
            message_text = message.to_s.gsub('/', '')
            check_result = Game.instance.check_suggestion(message_text)
            bot.api.send_message(chat_id: message.chat.id, text: check_result, parse_mode: 'Markdown')
          else
            bot.api.send_message(chat_id: message.chat.id, text: Constants::STARTED_NOT_ASKED)
          end
        else
          bot.api.send_message(chat_id: message.chat.id, text: Constants::NOT_STARTED)
        end
    end
  end
end
