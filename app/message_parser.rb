require_relative 'game_manager'
require_relative 'objects/reply'
require_relative 'misc/enums'
require_relative 'objects/keyboard'

class MessageParser
  def initialize
    @game_manager = GameManager.new
  end

  def parse_message(message)
    case message
      when Telegram::Bot::Types::CallbackQuery
        chat_id, type, direction = parse_message_data(message.data)
        case type
          when MessageType::ANSWER
            text = @game_manager.post_answer_to_game(message.data.to_i)
            Reply.new(message: text, chat_id: chat_id, callback_id: message.id)
          when MessageType::TELL
            text = @game_manager.post_answer_to_game(message.data.to_i, mode: :i_am_a_cheater)
            Reply.new(message: text, chat_id: message.from.id, callback_id: message.id)
          when MessageType::NEXT_QUESTION
            next_question(chat_id, private?(message), callback_id: message.id)
          when MessageType::NAVIGATION
            navigate_to(direction: direction, chat_id: chat_id)
          else
            fail "Incorrect message type '#{type}'"
        end
      when Telegram::Bot::Types::Message
        return if message.text.nil? || !message.text.start_with?('/')
        logger.info("#{message.text} is called in #{chat_name(message)}") unless ENV['TEST']
        id = message.chat.id
        # Check if user tries to play without starting
        if !%w(/start /stop /help).include?(message.text) && !@game_manager.on?(id)
          Reply.new(message: Constants::NOT_STARTED, chat_id: id)
          # Check if user tries to raise answer without asked question
        elsif !%w(/start /stop /help /next /sources /tours /random).include?(message.text) && !@game_manager.game(id).asked
          Reply.new(message: Constants::STARTED_NOT_ASKED, chat_id: id)
        else
          case message.text
            when '/start'
              Reply.new(message: @game_manager.start(id), chat_id: id)
            when '/stop'
              Reply.new(message: @game_manager.stop(id), chat_id: id)
            when '/help'
              Reply.new(message: Constants::HELP, chat_id: id)
            when '/next'
              next_question(id, private?(message))
            when '/answer'
              Reply.new(message: @game_manager.post_answer_to_game(id), chat_id: id)
            when '/repeat'
              Reply.new(message: @game_manager.game(id).question, chat_id: id)
            when '/sources'
              Reply.new(message: @game_manager.change_sources_state(id), chat_id: id)
            when '/tours'
              switch_to_tours(id)
            when '/random'
              Reply.new(message: @game_manager.switch_to_random(id), chat_id: id)
            else
              message_text = message.to_s.delete('/')
              check_result = @game_manager.check_suggestion_in_game(id, message_text)
              Reply.new(message: check_result, chat_id: id)
          end
        end
      else
        logger.warn("Unknown message type #{message.class}")
    end
  end

  private

  def next_question(id, private, callback_id: nil)
    if @game_manager.game(id).asked
      previous_answer = @game_manager.post_answer_to_game(id, mode: :to_last)
    end
    new_question = @game_manager.new_question_for_game(id)
    reply = Reply.new(message: new_question, chat_id: id, previous_answer: previous_answer)
    reply.markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: keyboard(id, private))
    if @game_manager.game(id).question_has_photo
      reply.photo = @game_manager.game(id).photo
    end
    if callback_id
      reply.callback_id = callback_id
    end
    reply
  end

  def switch_to_tours(id)
    switched = @game_manager.switch_to_tours(id)
    markup = @game_manager.tour_keyboard(chat_id: id)
    Reply.new(message: Constants::CHOOSE_TOUR, chat_id: id, markup: markup, previous_answer: switched)
  end

  def navigate_to(direction:, chat_id:)
    markup = @game_manager.tour_keyboard(chat_id: chat_id, direction: direction)
    Reply.new(chat_id: chat_id, markup: markup, type: ReplyType::EDIT)
  end

  def keyboard(id, private)
    buttons = [['Ответ',      "#{id}/answer"]]
    buttons << ['В личку',    "#{id}/tell"] unless private
    buttons << ['Следующий',  "#{id}/next_question"]
    Keyboard.new(buttons, id).get_horizontal
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

  def parse_message_data(data)
    chat_id, type, direction = data.scan(/^(-?\d+)\/([a-z_]+)(?:\/([a-z]+))?$/).first
    type = {
      'answer' => MessageType::ANSWER,
      'tell' => MessageType::TELL,
      'next_question' => MessageType::NEXT_QUESTION,
      'navigation' => MessageType::NAVIGATION
    }.fetch(type)
    direction = {
      'prev' => Navigation::PREVIOUS,
      'next' => Navigation::NEXT
    }.fetch(direction) unless direction.nil?
    [chat_id.to_i, type, direction]
  end

  def logger
    $stdout.sync = true
    @logger ||= Logger.new(STDOUT)
  end
end