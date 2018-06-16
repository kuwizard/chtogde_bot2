require_relative 'common'

# encoding: utf-8
class ScenariosWithButtonsTest < Test::Unit::TestCase
  include Common

  def setup
    @processor = BotProcessor.new(MessageParser.instance)
    @chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123', first_name: 'Test', last_name: 'User')
    db = DatabaseMock.new({})
    GameManager.instance.restore_previous_games(db)
    change_question_to('two_questions_no_pass_criteria.xml')
  end

  def teardown
    send_message('/stop')
  end

  def test_answer_button
    send_message('/start')
    reply = send_message('/next')
    reply = send_button_click(reply.answer_button)
    expected = "*Ответ*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, reply.message, 'Incorrect message on clicking answer button')
    assert_nil(reply.previous_answer, 'Previous answer is not nil')
  end

  def test_callback_id_on_answer_button
    send_message('/start')
    reply = send_message('/next')
    reply = send_button_click(reply.answer_button)
    assert_equal(@message_id, reply.callback_id, 'Incorrect callback id on answer button')
  end

  def test_next_button
    send_message('/start')
    reply = send_message('/next')
    change_question_to('second_question.xml')
    reply = send_button_click(reply.next_button)
    expected = '*Вопрос*: Вопрос со звёздочкой'
    assert_equal(expected, reply.message, 'Incorrect message on next button after previous question just asked')
    expected_previous = "*Ответ на предыдущий вопрос*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected_previous, reply.previous_answer, 'Incorrect message on next button after previous question just asked')
  end

  def test_callback_id_on_next_button
    send_message('/start')
    reply = send_message('/next')
    change_question_to('second_question.xml')
    reply = send_button_click(reply.next_button)
    assert_equal(@message_id, reply.callback_id, 'Incorrect callback id on next button')
  end
end