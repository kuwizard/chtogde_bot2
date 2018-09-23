require 'nokogiri'
require 'open-uri'
require_relative 'misc/constants'

class QuestionCollector
  def random_questions(amount)
    questions = []
    @url = "#{Constants::RANDOM_QUESTION_URL}limit#{amount}"
    xml.css('question').each do |question|
      questions << Question.new(question)
    end
    questions
  end

  def specific_question(tour_name:, question_id:)
    @url = "#{Constants::TOUR_URL}".gsub('%tour_name', tour_name)
    counter = question_id.to_i - 1
    Question.new(xml.css('question')[counter])
  end

  def tours_list(param:)
    param = '' if param.nil?
    @url = "#{Constants::TOUR_URL}".gsub('%tour_name', param)
    tours = xml.css('tour')
    tours.map { |tour| [tour.css('Title').inner_text, tour.css('TextId').inner_text] }
  end

  private

  def xml
    Nokogiri::XML(open(@url))
  end
end