require 'singleton'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'logger'
require 'open-uri'
require 'unicode_utils'

# noinspection RubyClassVariableUsageInspection
class Game
  include Singleton

  URL = 'https://db.chgk.info/xml/random/limit1'

  attr_accessor :question, :asked, :game_is_on, :logger

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

  def post_answer(finished: true, to_last: false)
    @asked = false if finished
    add_to_last = to_last ? ' к предыдущему вопросу' : ''
    "*Ответ#{add_to_last}*: #{answer}\n*Комментарий*: #{comment}"
  end

  def check_suggestion(suggested)
    if match?(suggested, answer)
      @asked = false
      "\"*#{suggested}*\" - это правильный ответ!\n*Комментарий*: #{comment}"
    else
      "\"*#{suggested}*\" - это неправильный ответ."
    end
  end

  def asked?
    @asked && !@asked.nil?
  end

  private

  def remove_shit(text)
    text.to_s.gsub(/<.*?>/, '').gsub(/\r/, ' ').gsub(/\n/, ' ').gsub(/\.$/, '')
  end

  def match?(expected_raw, actual_raw)
    expected = UnicodeUtils.downcase(expected_raw)
    actual = UnicodeUtils.downcase(actual_raw)
    matched = expected == actual
    logger.info("Suggested: #{expected}, answer is: #{actual_raw}. I think it is #{matched}")
    matched
  end

  def answer
    remove_shit(@question.css('Answer'))
  end

  def comment
    comment = remove_shit(@question.css('Comments'))
    comment = 'Отсутствует :(' if comment.empty?
    comment
  end

  def logger
    @logger || init_logger
  end

  def init_logger
    @logger = Logger.new(STDOUT)
    @logger.level = Logger.const_get((ENV['LOG_LEVEL'] || 'INFO').upcase)
    @logger
  end
end