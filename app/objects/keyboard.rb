require_relative '../misc/enums'

class Keyboard
  MAX_AMOUNT = 5

  def initialize(buttons, chat_id, level_up = false)
    @buttons = buttons
    @chat_id = chat_id
    @level_up = level_up
  end

  def get
    if @buttons.count <= 5
      buttons = @buttons
    else
      @from ||= 0
      buttons = @buttons[@from, MAX_AMOUNT]
      buttons << bottom_arrows(@from > 0, @from + MAX_AMOUNT < @buttons.count)
    end
    buttons.unshift(level_up_arrow) if @level_up && !buttons.empty?
    buttons_map(buttons) unless buttons.empty?
  end

  def next
    @from += MAX_AMOUNT
  end

  def previous
    @from -= MAX_AMOUNT
  end

  def get_horizontal
    [buttons_map(@buttons)]
  end

  private

  def buttons_map(buttons)
    buttons.map do |text, callback_data|
      if text.is_a?(Array)
        buttons_map(text)
      else
        Telegram::Bot::Types::InlineKeyboardButton.new(text: text, callback_data: callback_data)
      end
    end
  end

  def level_up_arrow
    [[['⬆️', "#{@chat_id}/navigation/level_up"]]]
  end

  def bottom_arrows(left, right)
    arrows = []
    arrows << ['⬅️', "#{@chat_id}/navigation/prev"] if left
    arrows << ['➡️', "#{@chat_id}/navigation/next"] if right
    [arrows]
  end
end