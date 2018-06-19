require_relative 'common'

# encoding: utf-8
class ScenariosInGroupChatTest < Test::Unit::TestCase
  include Common

  def setup
    @processor = BotProcessorMock.new
    @chat = Telegram::Bot::Types::Chat.new(type: 'group', id: '333', first_name: 'Group', last_name: 'User')
    change_question_to('two_questions_no_pass_criteria.xml')
  end

  def teardown
    send_message('/stop')
  end

  def test_answer_correctly_in_group
    send_message('/start')
    send_message('/next')
    reply = send_message('/быть')
    expected = "*быть* - это правильный ответ!\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on correct answer in group')
    assert_nil(reply.previous_answer, 'Previous answer is not nil')
  end

  def test_repeat_in_group
    send_message('/start')
    send_message('/next')
    reply = send_message('/repeat')
    expected = '*Вопрос*: Быть или не быть?'
    assert_equal(expected, reply.message, 'Incorrect message on /repeat after answer in group')
    assert_nil(reply.previous_answer, 'Previous answer is not nil')
  end

  def test_surrender_in_group
    send_message('/start')
    send_message('/next')
    reply = send_message('/answer')
    expected = "*Ответ*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on /answer in group')
    assert_nil(reply.previous_answer, 'Previous answer is not nil')
  end

  def test_next_on_asked_in_group
    send_message('/start')
    send_message('/next')
    change_question_to('second_question.xml')
    reply = send_message('/next')
    expected = '*Вопрос*: Вопрос со звёздочкой'
    assert_equal(expected, reply.message, 'Incorrect message on /next after previous question just asked in group')
    expected_previous = "*Ответ на предыдущий вопрос*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected_previous, reply.previous_answer, 'Incorrect message on /next after previous question just asked in group')
  end
end