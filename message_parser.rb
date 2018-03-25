require 'singleton'
require_relative 'game'

class MessageParser
  include Singleton

  attr_accessor :bot, :logger

  def parse_message(message)
    case message
      when Telegram::Bot::Types::CallbackQuery
        @bot.api.answer_callback_query(callback_query_id: message.id)
        if message.data.include?('answer')
          message.data.gsub!('answer', '')
          post(Game.instance.post_answer, message.data)
        end
        if message.data == 'tell'
          post(Game.instance.post_answer(finished: false), message.from.id)
        end
        if message.data.include?('next')
          message.data.gsub!('next', '')
          next_question(message.data)
        end
      when Telegram::Bot::Types::Message
        @logger.info("#{message.text} is called")
        case message.text
          when '/start'
            post(Game.instance.start, message.chat.id)
          when '/stop'
            post(Game.instance.stop, message.chat.id)
          when '/help'
            post(Constants.HELP, message.chat.id)
          when '/next'
            next_question(message.chat.id)
          when '/answer'
            if Game.instance.is_on?
              post(Game.instance.post_answer, message.chat.id)
            else
              post(Constants::NOT_STARTED, message.chat.id)
            end
          when '/repeat'
            if Game.instance.is_on?
              if Game.instance.asked?
                post(Game.instance.question, message.chat.id)
              else
                post(Constants::STARTED_NOT_ASKED, message.chat.id)
              end
            else
              post(Constants::NOT_STARTED, message.chat.id)
            end
          else
            if Game.instance.is_on?
              if Game.instance.asked?
                message_text = message.to_s.delete('/')
                check_result = Game.instance.check_suggestion(message_text)
                post(check_result, message.chat.id)
              else
                post(Constants::STARTED_NOT_ASKED, message.chat.id)
              end
            else
              post(Constants::NOT_STARTED, message.chat.id)
            end
        end
      else
        @logger.warn("Unknown message type #{message.class}")
    end
  rescue Telegram::Bot::Exceptions::ResponseError
    @logger.warn('Caught ResponseError')
  end

  def post(message, chat_id, **args)
    @bot.api.send_message(text: message, chat_id: chat_id, parse_mode: 'Markdown', **args)
  end

  def next_question(id)
    if Game.instance.is_on?
      if Game.instance.asked?
        post(Game.instance.post_answer(to_last: true), id)
      end
      kb = [
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Ответ', callback_data: "answer#{id}"),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'В личку', callback_data: 'tell'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Следующий', callback_data: "next#{id}")
        ]
      ]
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      new_question = Game.instance.new_question
      if Game.instance.question_contains_photo?
        @bot.api.send_photo(chat_id: id, photo: Game.instance.question_photo)
      end
      post(new_question, id, reply_markup: markup)
    else
      post(Constants::NOT_STARTED, id)
    end
  end

  def init(bot)
    $stdout.sync = true
    @bot ||= bot
    @logger ||= Logger.new(STDOUT)
  end
end