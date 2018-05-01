require 'pg'
require 'singleton'

class Database
  include Singleton
  @db

  def init
    db_name = ENV['DB_NAME']
    db_user = ENV['DB_USER']
    db_password = ENV['DB_PASSWORD']
    @db = PG.connect :dbname => db_name, :user => db_user, :password => db_password
  end

  def get(mode, chat_id)
    sleep 0.5
  end

  def save_asked_random(mode, chat_id:, question_id:)
    @db.query("INSERT INTO #{mode_to_table(mode)} (chat_id, question_id) VALUES (#{chat_id}, #{question_id});")
  end

  def delete_random(chat_id)
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
