require 'net/http'
require 'uri'
require 'logger'
require 'open-uri'
require 'unicode_utils'
require 'benchmark'
require_relative 'question'

class Game
  attr_reader :asked, :question_has_photo
  @logger
  @question

  def initialize
    @asked = false
  end

  def new_question
    @asked = true
    time = Benchmark.measure {
      @question = Question.new
    }
    @question_has_photo = !@question.photo.nil?
    log.info("Time to create a question: #{time.real}")
    @question.text
  end

  def post_answer(finished: true, to_last: false)
    @asked = false if finished
    to_last ? @question.answer_to_last_text : @question.answer_text
  end

  def check_suggestion(suggested)
    if match?(suggested, @question.answer)
      @asked = false
      "\"*#{suggested}*\" - это правильный ответ!\n#{@question.comment}"
    else
      "\"*#{suggested}*\" - это неправильный ответ."
    end
  end

  def photo
    @question.photo
  end

  private

  def match?(expected_raw, actual_raw)
    expected = UnicodeUtils.downcase(expected_raw)
    actual = UnicodeUtils.downcase(actual_raw)
    matched = expected == actual
    log.info("Suggested: #{expected}, answer is: #{actual_raw}. I think it is #{matched}")
    matched
  end

  def log
    @logger || init_logger
  end

  def init_logger
    @logger = Logger.new(STDOUT)
    @logger.level = Logger.const_get((ENV['LOG_LEVEL'] || 'INFO').upcase)
    @logger
  end
end