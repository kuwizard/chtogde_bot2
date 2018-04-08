require 'nokogiri'
require_relative 'constants'

class Question
  attr_reader :text, :comment, :answer, :answer_text, :answer_to_last_text, :photo
  @question_raw

  def initialize(question_xml)
    @question_raw = question_xml
    @text = "*Вопрос*: #{remove_shit(@question_raw.css('Question'))}"
    @comment = add_comment
    @answer = remove_shit(@question_raw.css('Answer'))
    @answer_text = "*Ответ*: #{@answer}\n#{@comment}"
    @answer_to_last_text = "*Ответ к предыдущему вопросу*: #{answer}\n#{@comment}"
    @photo = photo_value
  end

  private

  def photo_value
    question_text = @question_raw.css('Question').to_s
    if question_text.match(/\(pic: \d+\.[a-z]{3}\)/)
      img_path = question_text.scan(/\(pic: (\d+\.[a-z]{3})\)/).first.first
      "#{Constants::IMAGE_URL}#{img_path}"
    end
  end

  def remove_shit(text)
    text.to_s.gsub(/<.*?>/, '').gsub(/\r/, ' ').gsub(/\n/, ' ').gsub(/\.$/, '').gsub(/^"|"$/, '').gsub(/\(pic:.*\)/, '').strip
  end

  def add_comment
    comment = remove_shit(@question_raw.css('Comments'))
    if comment.empty?
      '*Комментарий*: Отсутствует :('
    else
      "*Комментарий*: #{comment}"
    end
  end
end