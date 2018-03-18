require 'singleton'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'logger'
require 'open-uri'

# noinspection RubyClassVariableUsageInspection
class Game
  include Singleton

  URL = 'https://db.chgk.info/xml/random/limit1'

  attr_accessor :question, :asked, :game_is_on

  @@logger = Logger.new(STDOUT)

  def start
    @game_is_on = true
  end

  def stop
    @game_is_on = false
  end

  def is_on?
    @game_is_on
  end

  def question
    xml = Nokogiri::XML(open(URL))
    @question = xml.css('question').first
    @asked = true
    "*Вопрос*: #{remove_shit(@question.css('Question'))}"
  end

  def post_answer
    @asked = false
    "*Ответ*: #{answer}\n*Комментарий*: #{comment}"
  end

  def check_suggestion(suggested)
    if match?(suggested, answer)
      @asked = false
      "\"#{suggested}\" - это правильный ответ!\n*Комментарий*: #{comment}"
    else
      "\"#{suggested}\" - это неправильный ответ."
    end
  end

  def asked?
    @asked && !@asked.nil?
  end

  private

  def remove_shit(text)
    text.to_s.gsub(/<.*?>/, '').gsub(/\r/, ' ').gsub(/\n/, ' ').gsub(/.$/, '')
  end

  def match?(expected_raw, actual_raw)
    expected = expected_raw.downcase
    actual = actual_raw.downcase
    matched = expected == actual
    @@logger.info("Suggested: #{expected}, answer is: #{actual}. I think it is #{matched}")
    matched
  end

  def answer
    remove_shit(@question.css('Answer'))
  end

  def comment
    comment = remove_shit(@question.css('Comments'))
    comment = 'Отсутствует :(' if comment.empty?
  end
end