require 'nokogiri'
require_relative 'constants'

class Question
  attr_reader :text, :comment, :answers_trimmed, :answer_text, :answer_to_last_text, :photo, :tour_name, :id, :sources
  @question_raw

  def initialize(question_xml)
    @question_raw = question_xml
    @text = "*Вопрос*: #{remove_shit(extract('Question'))}"
    @comment = add_comment
    @answers_trimmed = all_answers(remove_shit(extract('Answer')), remove_shit(extract('PassCriteria')))
    @answer_text = "#{all_answers_to_text(@answers_trimmed)}\n#{@comment}"
    @photo = photo_value
    @tour_name = extract_tour_name
    @id = extract('Number')
    @sources = remove_shit(extract('Sources'))
  end

  private

  def extract(node_text)
    @question_raw.css(node_text).inner_text
  end

  def photo_value
    question_text = @question_raw.css('Question').to_s
    if question_text.match(/\(pic: \d+\.[a-z]{3}\)/)
      img_path = question_text.scan(/\(pic: (\d+\.[a-z]{3})\)/).first.first
      "#{Constants::IMAGE_URL}#{img_path}"
    end
  end

  def remove_shit(text)
    text.to_s.gsub(/\r/, ' ')
        .gsub(/\n/, ' ')
        .gsub('_', "\\_")
        .gsub(/\(pic:.*\)/, '').strip
  end

  def remove_shit_at_all(text)
    text.gsub(/\.$/, '') # If dot is at the end
        .gsub(/^"(.+(?="$))"$/, '\1') # Delete quotes but only if they are leading and trailing
        .gsub(/^\.\.\./, '') # Delete three dots at the beginning
        .strip
  end

  def add_comment
    comment = extract('Comments')
    comment = remove_shit(comment)
    if comment.empty?
      '*Комментарий*: Отсутствует :('
    else
      "*Комментарий*: #{comment}"
    end
  end

  def extract_tour_name
    probable_tour_name = extract('tourFileName')
    if probable_tour_name.empty?
      extract('TextId').gsub(/-\d+$/, '')
    else
      probable_tour_name
    end
  end

  def all_answers(answer_original, pass_criterias)
    answers = [remove_shit_at_all(answer_original)]
    pass_criterias.split(/\.|,/).each do |e|
      answers.push(remove_shit_at_all(e))
    end
    answers
  end

  def all_answers_to_text(answers)
    answers.join('/')
  end
end