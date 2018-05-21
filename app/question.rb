require 'nokogiri'
require_relative 'constants'

class Question
  attr_reader :text, :comment, :answer_original, :answers_trimmed, :answer_text, :answer_to_last_text, :photo, :tour_name, :id, :pass_criteria
  @question_raw

  def initialize(question_xml)
    @question_raw = question_xml
    @text = "*Вопрос*: #{remove_shit(extract('Question'))}"
    @comment = add_comment
    @answer_original = remove_shit(extract('Answer'))
    @pass_criteria = remove_shit(extract('PassCriteria'))
    @answers_trimmed = all_answers
    add_to_answer = @pass_criteria.empty? ? '' : "/#{@pass_criteria}"
    @answer_text = "#{@answer_original}#{add_to_answer}\n#{@comment}"
    @photo = photo_value
    @tour_name = extract_tour_name
    @id = extract('Number')
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

  def all_answers
    answers = [remove_shit_at_all(@answer_original)]
    @pass_criteria.split(/\.|,/).each do |e|
      answers.push(remove_shit_at_all(e))
    end
    answers
  end
end