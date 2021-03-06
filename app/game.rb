require 'net/http'
require 'logger'
require 'unicode_utils'
require_relative 'question_collector'
require_relative 'question'

class Game
  attr_reader :asked, :question_has_photo, :sources

  def initialize(chat_id:, tour_name: nil, question_id: nil, asked: 'f', sources: false)
    @asked = false
    @sources = false
    @questions = []
    @chat_id = chat_id
    @question_collector ||= QuestionCollector.new
    if tour_name && question_id # Which means we're restoring games from DB
      add_specific_question(tour_name: tour_name, question_id: question_id)
      @asked = asked == 't'
      @sources = sources
    else
      add_random_questions(1)
    end
  end

  def new_question
    @asked = true
    @question_collector_thread.join unless @question_collector_thread.nil?
    @question = @questions.first
    @questions.shift
    @question_has_photo = !@question.photo.nil?
    add_random_questions(1)
    @question
  end

  def post_answer(mode: :normal)
    unless mode == :i_am_a_cheater
      @asked = false
    end
    answer = answer_start(mode: mode) + @question.answer_text
    answer += formatted_sources(@question.sources) if @sources
    answer
  end

  def check_suggestion(suggested)
    answers = @question.answers_trimmed
    if match?(suggested, answers)
      @asked = false
      leftover = leftover(suggested, answers)
      output = "*#{suggested}*#{leftover} - это правильный ответ!\n#{@question.comment}"
      output += formatted_sources(@question.sources) if @sources
      return true, output
    else
      return false, "*#{suggested}* - это неправильный ответ."
    end
  end

  def photo
    @question.photo
  end

  def question
    @question.text
  end

  def change_sources_state
    @sources = !@sources
  end

  private

  def match?(expected_raw, actual_array)
    expected = downcase(expected_raw)
    actual = actual_array.map { |e| downcase(e) }
    match = actual.include?(expected)
    log.info("Suggested: #{expected}, answers: #{actual_array}. I think it is #{match}") unless ENV['TEST']
    match
  end

  def leftover(suggested, answers)
    leftover = answers.select { |e| downcase(e) != downcase(suggested) }
    leftover.empty? ? '' : "/#{leftover.join('/')}"
  end

  def log
    @logger || init_logger
  end

  def init_logger
    @logger = Logger.new(STDOUT)
    @logger.level = Logger.const_get((ENV['LOG_LEVEL'] || 'INFO').upcase)
    @logger
  end

  def add_random_questions(up_to_size = 3)
    @question_collector_thread = Thread.new do
      amount_needed = up_to_size - @questions.size
      @questions += @question_collector.random_questions(amount_needed) unless amount_needed < 1
    end
  end

  def add_specific_question(tour_name:, question_id:)
    @questions << @question_collector.specific_question(tour_name: tour_name, question_id: question_id)
    new_question.text
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
        '*Ответ*: '
      else
        fail "Unknown answer mode '#{mode}'"
    end
  end

  def formatted_sources(sources)
    array = sources.split(/(\D|^)\d\.\ /).map(&:strip).reject(&:empty?)
    output = array.empty? ? ' не указаны' : "\n#{array.join("\n")}"
    "\n*Источники*:#{output}"
  end

  def downcase(string)
    UnicodeUtils.downcase(string)
  end
end