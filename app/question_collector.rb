require 'nokogiri'
require 'open-uri'
require_relative 'constants'

class QuestionCollector
  def self.random_questions(amount)
    questions = []
    @url = "#{Constants::RANDOM_QUESTION_URL}limit#{amount}"
    xml.css('question').each do |question|
      questions << Question.new(question)
    end
    questions
  end

  def self.specific_question(tour_name:, question_id:)
    @url = "#{Constants::TOUR_QUESTION_URL}".gsub('%tour_name', tour_name)
    counter = question_id.to_i - 1
    Question.new(xml.css('question')[counter])
  end

  private

  def self.xml
    if ENV['TEST']
      File.open('../tests/data/question.xml') { |f| Nokogiri::XML(f) }
    else
      Nokogiri::XML(open(@url))
    end
  end
end