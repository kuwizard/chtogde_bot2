require 'pg'

class Database
  def initialize
    db_host = ENV['DB_HOST']
    db_port = ENV['DB_PORT']
    db_name = ENV['DB_NAME']
    db_user = ENV['DB_USER']
    db_password = ENV['DB_PASSWORD']
    @db = PG.connect :host => db_host, :port => db_port, :dbname => db_name, :user => db_user, :password => db_password
  end

  def list_of_games(mode)
    result = @db.query("SELECT chat_id FROM #{mode_to_table(mode)};")
    result.column_values(0).map(&:to_i)
  end

  def get_question(mode, chat_id:)
    result = @db.query("SELECT tour_name, question_id, asked FROM #{mode_to_table(mode)} WHERE chat_id='#{chat_id}';")
    result[0]
  end

  def save_asked(mode, chat_id:, tour_name:, question_id:)
    if list_of_games(mode).include?(chat_id)
      @db.query("UPDATE #{mode_to_table(mode)} SET tour_name = '#{tour_name}', question_id = '#{question_id}', asked = true WHERE chat_id = '#{chat_id}';")
    else
      @db.query("INSERT INTO #{mode_to_table(mode)} (chat_id, tour_name, question_id, asked) VALUES ('#{chat_id}', '#{tour_name}' ,'#{question_id}', true);")
    end
  end

  def set_asked_to_false(mode, chat_id:)
    @db.query("UPDATE #{mode_to_table(mode)} SET asked = false WHERE chat_id = '#{chat_id}';")
  end

  def delete_random(mode, chat_id:)
    @db.query("DELETE FROM #{mode_to_table(mode)} WHERE chat_id='#{chat_id}';")
  end

  private

  def mode_to_table(mode)
    case mode
      when :random
        'random'
      when :tour
        'tour'
      else
        fail "Incorrect game mode #{mode}"
    end
  end
end
