require 'nokogiri'
require 'open-uri'
require_relative 'constants'

class QuestionCollector
  attr_reader :file

  def initialize(file = nil)
    @file = file
  end

  def random_questions(amount)
    questions = []
    @url = "#{Constants::RANDOM_QUESTION_URL}limit#{amount}"
    xml.css('question').each do |question|
      questions << Question.new(question)
    end
    questions
  end

  def specific_question(tour_name:, question_id:)
    @url = "#{Constants::TOUR_QUESTION_URL}".gsub('%tour_name', tour_name)
    counter = question_id.to_i - 1
    Question.new(xml.css('question')[counter])
  end

  private

  def xml
    if @file
      File.open("#{Constants::FILE_PATH}#{@file}") { |f| Nokogiri::XML(f) }
    else
      Nokogiri::XML(open(@url))
    end
  end
end