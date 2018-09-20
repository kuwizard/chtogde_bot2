require_relative '../misc/enums'

class Keyboard
  AMOUNT = 5

  def initialize(buttons, chat_id)
    @buttons = buttons
    @chat_id = chat_id
  end

  def get
    if @buttons.count <= 5
      buttons_map(@buttons)
    else
      @from ||= 0
      output = @buttons[@from, AMOUNT]
      if @from > 0
        output.unshift(['⬅️', "#{@chat_id}/navigation/prev"])
      end
      if @from + AMOUNT < @buttons.count
        output << ['➡️', "#{@chat_id}/navigation/next"]
      end
      buttons_map(output)
    end
  end

  def next
    @from += AMOUNT
  end

  def previous
    @from -= AMOUNT
  end

  def get_horizontal
    [buttons_map(@buttons)]
  end

  private def buttons_map(buttons)
    buttons.map do |text, callback_data|
      Telegram::Bot::Types::InlineKeyboardButton.new(text: text, callback_data: callback_data)
    end
  end
end