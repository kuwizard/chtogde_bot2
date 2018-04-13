require 'net/http'
require 'uri'
require 'logger'
require 'open-uri'
require 'unicode_utils'
require_relative 'question_collector'
require_relative 'question'

class Game
  attr_reader :asked, :question_has_photo
  @logger
  @questions
  @question
  @question_collector_thread
  @cheater_detected

  def initialize
    @asked = false
    @questions = []
    add_questions(1)
  end

  def new_question
    @asked = true
    @question_collector_thread.join
    @question = @questions.first
    @questions.shift
    @question_has_photo = !@question.photo.nil?
    add_questions(3)
    @question.text
  end

  def post_answer(mode: :normal)
    @asked = false unless mode == :i_am_a_cheater
    answer_start(mode: mode) + @question.answer_text
  end

  def check_suggestion(suggested)
    if match?(suggested, @question.answer_trimmed)
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

  def add_questions(up_to_size = 3)
    @question_collector_thread = Thread.new do
      amount_needed = up_to_size - @questions.size
      @questions += QuestionCollector.questions(amount_needed) unless amount_needed < 1
    end
  end

  def cheated_text
    @cheater_detected ? ' (который кое-кто уже подсмотрел)' : ''
  end

  def answer_start(mode:)
    case mode
      when :normal
        "*Ответ#{cheated_text}*: "
      when :to_last
        "*Ответ на предыдущий вопрос#{cheated_text}*: "
      when :i_am_a_cheater
        @cheater_detected = true
        '*Ответ *: '
      else
        fail "Unknown answer mode '#{mode}'"
    end
  end
end