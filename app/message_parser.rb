require 'singleton'
require_relative 'game_manager'
require_relative 'reply'

class MessageParser
  include Singleton

  def parse_message(message)
    case message
      when Telegram::Bot::Types::CallbackQuery
        if message.data.include?('answer')
          message.data.gsub!('answer', '')
          Reply.new(GameManager.instance.game(message.data.to_i).post_answer, message.data)
        elsif message.data.include?('tell')
          message.data.gsub!('tell', '')
          Reply.new(GameManager.instance.game(message.data.to_i).post_answer(mode: :i_am_a_cheater), message.from.id)
        elsif message.data.include?('next')
          message.data.gsub!('next', '')
          next_question(message.data.to_i, private?(message))
        else
          fail "Cannot parse message.data '#{message.data}'"
        end
      when Telegram::Bot::Types::Message
        return unless message.text.start_with?('/')
        logger.info("#{message.text} is called in #{chat_name(message)}")
        id = message.chat.id
        # Check if user tries to play without starting
        if !%w(/start /stop /help).include?(message.text) && !GameManager.instance.on?(id)
          Reply.new(Constants::NOT_STARTED, id)
          # Check if user tries to raise answer without asked question
        elsif !%w(/start /stop /help /next /answer).include?(message.text) && !GameManager.instance.game(id).asked
          Reply.new(Constants::STARTED_NOT_ASKED, id)
        else
          case message.text
            when '/start'
              Reply.new(GameManager.instance.start(id), id)
            when '/stop'
              Reply.new(GameManager.instance.stop(id), id)
            when '/help'
              Reply.new(Constants::HELP, id)
            when '/next'
              next_question(id, private?(message))
            when '/answer'
              Reply.new(GameManager.instance.game(id).post_answer, id)
            when '/repeat'
              Reply.new(GameManager.instance.game(id).question, id)
            else
              message_text = message.to_s.delete('/')
              check_result = GameManager.instance.game(id).check_suggestion(message_text)
              Reply.new(check_result, id)
          end
        end
      else
        logger.warn("Unknown message type #{message.class}")
    end
  end

  private

  def next_question(id, private)
    if GameManager.instance.game(id).asked
      previous_answer = GameManager.instance.game(id).post_answer(mode: :to_last)
    end
    new_question = GameManager.instance.game(id).new_question
    reply = Reply.new(new_question, id, previous_answer)
    reply.markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: keyboard(id, private))
    if GameManager.instance.game(id).question_has_photo
      reply.photo = GameManager.instance.game(id).photo
    end
    reply
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

  def logger
    $stdout.sync = true
    @logger ||= Logger.new(STDOUT)
  end
end