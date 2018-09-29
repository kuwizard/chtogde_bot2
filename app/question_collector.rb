require 'nokogiri'
require 'open-uri'
require_relative 'misc/constants'

class QuestionCollector
  def random_questions(amount)
    @url = "#{Constants::RANDOM_QUESTION_URL}limit#{amount}"
    xml.css('question').map { |question| Question.new(question) }
  end

  def specific_question(tour_name:, question_id: nil)
    @url = tour_url(tour_name)
    counter = question_id.nil? ? 0 : question_id.to_i - 1
    Question.new(xml.css('question')[counter])
  end

  def all_questions_and_name(tour_name:)
    @url = tour_url(tour_name)
    cached_xml = xml
    questions_elements = cached_xml.css('question')
    count = questions_elements.count
    questions = questions_elements.each_with_index.map { |q, index| Question.new(q, number_in_tour: " #{index+1}/#{count}") }
    name = cached_xml.css('Title').inner_text
    [questions, name]
  end

  def tours_list(param:)
    param = '' if param.nil?
    @url = tour_url(param)
    tours = xml.css('tour')
    tours.map { |tour| [tour.css('Title').inner_text, tour.css('TextId').inner_text] }
  end

  private

  def xml
    Nokogiri::XML(open(@url))
  end

  def tour_url(to_replace)
    "#{Constants::TOUR_URL}".gsub('%tour_name', to_replace)
  end
end