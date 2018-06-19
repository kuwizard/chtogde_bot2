require_relative 'common'

# encoding: utf-8
class ScenariosWithPassCriteriasTest < Test::Unit::TestCase
  include Common

  def setup
    @processor = BotProcessorMock.new
    @chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123', first_name: 'Test', last_name: 'User')
    change_question_to('question_two_pass_criterias.xml')
  end

  def teardown
    send_message('/stop')
  end

  def test_answer_correctly_first_with_one_pass_criteria
    change_question_to('question_one_pass_criteria.xml')
    send_message('/start')
    send_message('/next')
    reply = send_message('/быть')
    expected = "*быть*/Не быть - это правильный ответ!\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on correct answer')
  end

  def test_answer_correctly_second_with_one_pass_criteria
    change_question_to('question_one_pass_criteria.xml')
    send_message('/start')
    send_message('/next')
    reply = send_message('/не быть')
    expected = "*не быть*/Быть - это правильный ответ!\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on correct answer')
  end

  def test_answer_correctly_first_with_two_pass_criterias
    send_message('/start')
    send_message('/next')
    reply = send_message('/быть')
    expected = "*быть*/Не быть/Не знаю - это правильный ответ!\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on correct answer')
  end

  def test_answer_correctly_second_with_two_pass_criterias
    send_message('/start')
    send_message('/next')
    reply = send_message('/не быть')
    expected = "*не быть*/Быть/Не знаю - это правильный ответ!\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on correct answer')
  end

  def test_answer_correctly_third_with_two_pass_criterias
    send_message('/start')
    send_message('/next')
    reply = send_message('/Не ЗНАЮ')
    expected = "*Не ЗНАЮ*/Быть/Не быть - это правильный ответ!\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on correct answer')
  end

  def test_surrender_with_pass_criteria
    send_message('/start')
    send_message('/next')
    reply = send_message('/answer')
    expected = "*Ответ*: Быть/Не быть/Не знаю\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on /answer')
  end

  def test_next_on_asked_with_pass_criteria
    send_message('/start')
    send_message('/next')
    change_question_to('second_question.xml')
    reply = send_message('/next')
    expected = '*Вопрос*: Вопрос со звёздочкой'
    assert_equal(expected, reply.message, 'Incorrect message on /next after previous question just asked')
    expected_previous = "*Ответ на предыдущий вопрос*: Быть/Не быть/Не знаю\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected_previous, reply.previous_answer, 'Incorrect message on /next after previous question just asked')
  end
end