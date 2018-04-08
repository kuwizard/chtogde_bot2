require 'nokogiri'
require_relative 'constants'

class QuestionCollector
  def self.questions(amount)
    questions = []
    url = "#{Constants::GAME_URL}limit#{amount}"
    xml = Nokogiri::XML(open(url))
    xml.css('question').each do |question|
      questions << Question.new(question)
    end
    questions
  end
end