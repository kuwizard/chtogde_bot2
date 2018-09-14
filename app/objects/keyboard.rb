require_relative '../misc/enums'

class Keyboard
  def self.create(type, buttons)
    case type
      when KbType::HORIZONTAL
          buttons.map do |text, callback_data|
            Telegram::Bot::Types::InlineKeyboardButton.new(text: text, callback_data: callback_data)
          end
      when KbType::VERTICAL

      else
        raise("Unknown keyboard type #{type}")
    end
  end
end