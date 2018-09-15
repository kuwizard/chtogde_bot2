class BotProcessor
  def initialize(bot = nil)
    @parser = MessageParser.new
    @bot = bot
  end

  def process_message(message)
    if message.is_a?(Telegram::Bot::Types::Message)
      message.text = message.text.gsub(Constants::BOT_NAME, '') unless message.text.nil?
    end

    @parser.parse_message(message)
  end

  def post_reply(reply)
    chat_id = reply.chat_id

    if reply.callback_id
      answer_callback(reply.callback_id)
    end
    if reply.previous_answer
      post(reply.previous_answer, chat_id)
    end
    if reply.photo
      post_photo(reply.photo, chat_id)
    end
    if reply.markup
      last_message = post_with_markup(reply.message, chat_id, reply.markup)
      @last_message_id = last_message['result']['message_id']
    else
      post(reply.message, chat_id)
    end
  end

  private

  def post(message, chat_id)
    @bot.api.send_message(text: message, chat_id: chat_id, parse_mode: 'Markdown')
  end

  def post_with_markup(message, chat_id, markup)
    @bot.api.send_message(text: message, chat_id: chat_id, parse_mode: 'Markdown', reply_markup: markup)
  end

  def post_photo(photo, id)
    @bot.api.send_photo(photo: photo, chat_id: id)
  end

  def answer_callback(id)
    @bot.api.answer_callback_query(callback_query_id: id)
  rescue Telegram::Bot::Exceptions::ResponseError
    logger.warn('Caught ResponseError')
  end

  def logger
    $stdout.sync = true
    @logger ||= Logger.new(STDOUT)
  end
end