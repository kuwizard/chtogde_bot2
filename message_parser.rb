require 'singleton'
require_relative 'game'

class MessageParser
  include Singleton

  attr_accessor :bot, :logger

  def parse_message(message, bot)
    @bot ||= bot

    @logger ||= Logger.new(STDOUT)
    @logger.info("#{message.text} is called")

    case message.text
      when '/start'
        answer(Game.instance.start, message.chat.id)
      when '/stop'
        answer(Game.instance.stop, message.chat.id)
      when '/help'
        answer(Constants.HELP, message.chat.id)
      when '/next'
        if Game.instance.is_on?
          if Game.instance.asked?
            answer(Game.instance.post_answer(to_last: true), message.chat.id)
          end
          answer(Game.instance.new_question, message.chat.id)
        else
          answer(Constants::NOT_STARTED, message.chat.id)
        end
      when '/answer'
        if Game.instance.is_on?
          answer(Game.instance.post_answer, message.chat.id)
        else
          answer(Constants::NOT_STARTED, message.chat.id)
        end
      when '/repeat'
        if Game.instance.is_on?
          if Game.instance.asked?
            answer(Game.instance.question, message.chat.id)
          else
            answer(Constants::STARTED_NOT_ASKED, message.chat.id)
          end
        else
          answer(Constants::NOT_STARTED, message.chat.id)
        end
      when '/tellme'
        if Game.instance.asked?
          answer(Game.instance.post_answer(finished: false), message.chat.id)
        else
          answer(Constants::NOT_STARTED, message.chat.id)
        end
      else
        if Game.instance.is_on?
          if Game.instance.asked?
            message_text = message.to_s.delete('/')
            check_result = Game.instance.check_suggestion(message_text)
            answer(check_result, message.chat.id)
          else
            answer(Constants::STARTED_NOT_ASKED, message.chat.id)
          end
        else
          answer(Constants::NOT_STARTED, message.chat.id)
        end
    end
  end

  def answer(message, chat_id)
    @bot.api.send_message(text: message, chat_id: chat_id, parse_mode: 'Markdown')
  end
end