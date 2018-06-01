require_relative 'common'

# encoding: utf-8
class ScenariosWithTextTest < Test::Unit::TestCase
  include Common

  def setup
    @processor = BotProcessor.new(MessageParser.instance)
    @chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123', first_name: 'Test', last_name: 'User')
    db = DatabaseMock.new({})
    GameManager.instance.restore_previous_games(db)
    change_question_to('question_no_pass_criteria.xml')
  end

  def teardown
    send_message('/stop')
  end

  def test_answer_incorrectly
    send_message('/start')
    send_message('/next')
    reply = send_message('/фигня')
    expected = '*фигня* - это неправильный ответ.'
    assert_equal(expected, reply.message, 'Incorrect message on incorrect answer')
    assert_nil(reply.previous_answer, 'Previous answer is not nil')
  end

  def test_answer_correctly_primary
    send_message('/start')
    send_message('/next')
    reply = send_message('/быть')
    expected = "*быть* - это правильный ответ!\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on correct answer')
    assert_nil(reply.previous_answer, 'Previous answer is not nil')
  end

  def test_answer_correctly_upcase
    send_message('/start')
    send_message('/next')
    reply = send_message('/БЫТЬ')
    expected = "*БЫТЬ* - это правильный ответ!\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on correct UPPERCASE answer')
    assert_nil(reply.previous_answer, 'Previous answer is not nil')
  end

  def test_repeat
    send_message('/start')
    send_message('/next')
    reply = send_message('/repeat')
    expected = '*Вопрос*: Быть или не быть?'
    assert_equal(expected, reply.message, 'Incorrect message on /repeat after answer')
    assert_nil(reply.previous_answer, 'Previous answer is not nil')
  end

  def test_surrender
    send_message('/start')
    send_message('/next')
    reply = send_message('/answer')
    expected = "*Ответ*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on /answer')
    assert_nil(reply.previous_answer, 'Previous answer is not nil')
  end

  def test_next_on_asked
    send_message('/start')
    send_message('/next')
    change_question_to('second_question.xml')
    reply = send_message('/next')
    expected = '*Вопрос*: Вопрос со звёздочкой'
    assert_equal(expected, reply.message, 'Incorrect message on /next after previous question just asked')
    expected_previous = "*Ответ на предыдущий вопрос*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected_previous, reply.previous_answer, 'Incorrect message on /next after previous question just asked')
  end

  def test_start_after_asked_does_not_erase_question
    send_message('/start')
    send_message('/next')
    send_message('/start')
    reply = send_message('/быть')
    expected = "*быть* - это правильный ответ!\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message in case when we sent /start after question being asked')
    assert_nil(reply.previous_answer, 'Previous answer is not nil')
  end

  def test_next_after_answer_does_not_contain_previous_answer
    send_message('/start')
    send_message('/next')
    send_message('/answer')
    reply = send_message('/next')
    assert_nil(reply.previous_answer, 'Previous answer is not nil')
  end
end