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
        parse_message_data(message.data)
        if message.data.include?('answer')
          message.data.gsub!('answer', '')
          text = @game_manager.post_answer_to_game(message.data.to_i)
          Reply.new(message: text, chat_id: message.data, callback_id: message.id)
        elsif message.data.include?('tell')
          message.data.gsub!('tell', '')
          text = @game_manager.post_answer_to_game(message.data.to_i, mode: :i_am_a_cheater)
          Reply.new(message: text, chat_id: message.from.id, callback_id: message.id)
        elsif message.data.include?('next_question')
          message.data.gsub!('next_question', '')
          next_question(message.data.to_i, private?(message), callback_id: message.id)
        elsif message.data.include?('navigation')
          message.data.gsub!('navigation', '')
          navigate_to(direction: message.data, chat_id: message.data.to_i)
        else
          fail "Cannot parse message.data '#{message.data}'"
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
    Reply.new(message: Constants::CHOOSE_TOUR, chat_id: id, markup: @game_manager.tour_keyboard(chat_id: id), previous_answer: switched)
  end

  def navigate_to(direction)
    direction = if direction == 'prev'
                  Navigation::PREVIOUS
                elsif direction == 'next'
                  Navigation::NEXT
                else
                  raise("Incorrect direction '#{direction}'")
                end
    Reply.new(chat_id: id, markup: @game_manager.tour_keyboard(direction), type: ReplyType::EDIT)
  end

  def keyboard(id, private)
    buttons = [['Ответ',      "answer#{id}"]]
    buttons << ['В личку',    "tell#{id}"] unless private
    buttons << ['Следующий',  "next#{id}"]
    Keyboard.new(buttons).get_horizontal
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