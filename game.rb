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

  def post_answer(finished: true)
    @asked = false if finished
    "*Ответ*: #{answer}\n*Комментарий*: #{comment}"
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
    text.to_s.gsub(/<.*?>/, '').gsub(/\r/, ' ').gsub(/\n/, ' ').gsub(/.$/, '')
  end

  def match?(expected_raw, actual_raw)
    expected = UnicodeUtils.downcase(expected_raw)
    actual = UnicodeUtils.downcase(actual_raw)
    matched = expected == actual
    @@logger.info("Suggested: #{expected}, answer is: #{actual}. I think it is #{matched}")
    matched
  end

  def answer
    remove_shit(@question.css('Answer'))
  end

  def comment
    remove_shit(@question.css('Comments')).empty?
    comment = 'Отсутствует :(' if comment
    comment
  end
end