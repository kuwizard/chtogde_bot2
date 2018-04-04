require 'net/http'
require 'uri'
require 'nokogiri'
require 'logger'
require 'open-uri'
require 'unicode_utils'
require_relative 'constants'

class Game
  attr_accessor :question_raw, :asked, :logger, :photo

  def new_question
    xml = Nokogiri::XML(open(Constants::GAME_URL))
    @question_raw = xml.css('question').first
    @asked = true
    @photo = photo_value
    question
  end

  def question
    "*Вопрос*: #{remove_shit(@question_raw.css('Question'))}"
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

  def question_contains_photo?
    !@photo.nil?
  end

  def question_photo
    @photo
  end

  private

  def remove_shit(text)
    text.to_s.gsub(/<.*?>/, '').gsub(/\r/, ' ').gsub(/\n/, ' ').gsub(/\.$/, '').gsub(/\(pic:.*\)/, '').strip
  end

  def match?(expected_raw, actual_raw)
    expected = UnicodeUtils.downcase(expected_raw)
    actual = UnicodeUtils.downcase(actual_raw)
    matched = expected == actual
    log.info("Suggested: #{expected}, answer is: #{actual_raw}. I think it is #{matched}")
    matched
  end

  def answer
    remove_shit(@question_raw.css('Answer'))
  end

  def comment
    comment = remove_shit(@question_raw.css('Comments'))
    comment = 'Отсутствует :(' if comment.empty?
    comment
  end

  def log
    @logger || init_logger
  end

  def init_logger
    @logger = Logger.new(STDOUT)
    @logger.level = Logger.const_get((ENV['LOG_LEVEL'] || 'INFO').upcase)
    @logger
  end

  def photo_value
    question_text = @question_raw.css('Question').to_s
    if question_text.match(/\(pic: \d+\.[a-z]{3}\)/)
      img_path = question_text.scan(/\(pic: (\d+\.[a-z]{3})\)/).first.first
      "#{Constants::IMAGE_URL}#{img_path}"
    end
  end
end