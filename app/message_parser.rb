require 'singleton'
require 'benchmark'
require_relative 'game_manager'

class MessageParser
  include Singleton

  attr_accessor :bot, :logger

  def parse_message(message)
    case message
      when Telegram::Bot::Types::CallbackQuery
        @bot.api.answer_callback_query(callback_query_id: message.id)
        if message.data.include?('answer')
          message.data.gsub!('answer', '')
          post(GameManager.instance.game(message.data.to_i).post_answer, message.data)
        end
        if message.data.include?('tell')
          message.data.gsub!('tell', '')
          post(GameManager.instance.game(message.data.to_i).post_answer(finished: false), message.from.id)
        end
        if message.data.include?('next')
          message.data.gsub!('next', '')
          next_question(message.data.to_i, private?(message))
        end
      when Telegram::Bot::Types::Message
        @logger.info("#{message.text} is called in #{chat_name(message)}")
        id = message.chat.id
        # Check if user tries to play without starting
        if !%w(/start /stop /help).include?(message.text) && !GameManager.instance.on?(id)
          post(Constants::NOT_STARTED, id)
          # Check if user tries to raise answer without asked question
        elsif !%w(/start /stop /help /next).include?(message.text) && !GameManager.instance.game(id).asked
          post(Constants::STARTED_NOT_ASKED, id)
        else
          case message.text
            when '/start'
              post(GameManager.instance.start(id), id)
            when '/stop'
              post(GameManager.instance.stop(id), id)
            when '/help'
              post(Constants::HELP, id)
            when '/next'
              next_question(id, private?(message))
            when '/answer'
              post(GameManager.instance.game(id).post_answer, id)
            when '/repeat'
              post(GameManager.instance.game(id).question, id)
            else
              message_text = message.to_s.delete('/')
              check_result = GameManager.instance.game(id).check_suggestion(message_text)
              post(check_result, id)
          end
        end
      else
        @logger.warn("Unknown message type #{message.class}")
    end
  rescue Telegram::Bot::Exceptions::ResponseError
    @logger.warn('Caught ResponseError')
  end

  def init(bot)
    $stdout.sync = true
    @bot ||= bot
    @logger ||= Logger.new(STDOUT)
  end

  private

  def post(message, chat_id, **args)
    @bot.api.send_message(text: message, chat_id: chat_id, parse_mode: 'Markdown', **args)
  end

  def next_question(id, private)
    if GameManager.instance.on?(id)
      if GameManager.instance.game(id).asked
        post(GameManager.instance.game(id).post_answer(to_last: true), id)
      end
      new_question = nil
      time = Benchmark.measure {
        new_question = GameManager.instance.game(id).new_question
      }
      @logger.info("Time to get a question: #{time.real}")
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: keyboard(id, private))
      if GameManager.instance.game(id).question_has_photo
        @bot.api.send_photo(chat_id: id, photo: GameManager.instance.game(id).photo)
      end
      post(new_question, id, reply_markup: markup)
    else
      post(Constants::NOT_STARTED, id)
    end
  end

  def keyboard(id, private)
    kb = [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Ответ', callback_data: "answer#{id}")]
    unless private
      kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: 'В личку', callback_data: "tell#{id}")
    end
    kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Следующий', callback_data: "next#{id}")
    [kb]
  end

  def private?(message)
    if message.instance_of?(Telegram::Bot::Types::CallbackQuery)
      message = message.message # In this type Telegram stores data a bit differently
    end
    message.chat.type == 'private'
  end

  def chat_name(message)
    if private?(message)
      "private chat with #{message.chat.first_name} #{message.chat.last_name}"
    else
      "group chat called '#{message.chat.title}'"
    end
  end
end