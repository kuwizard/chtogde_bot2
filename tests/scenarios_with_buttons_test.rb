require_relative 'common'

# encoding: utf-8
class ScenariosWithButtonsTest < Test::Unit::TestCase
  include Common

  def setup
    @processor = BotProcessorMock.new
    @chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123', first_name: 'Test', last_name: 'User')
    change_question_to('two_questions_no_pass_criteria.xml')
    send_message('/start')
    send_message('/next')
  end

  def teardown
    send_message('/stop')
  end

  def test_two_buttons
    assert_equal(2, @reply.buttons_count, 'Incorrect number of buttons in reply')
  end

  def test_answer_button
    send_button_click(@reply.answer_button)
    expected = "*Ответ*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, @reply.message, 'Incorrect message on clicking answer button')
    assert_nil(@reply.previous_answer, 'Previous answer is not nil')
  end

  def test_callback_id_on_answer_button
    send_button_click(@reply.answer_button)
    assert_equal(@message_id, @reply.callback_id, 'Incorrect callback id on answer button')
  end

  def test_next_button
    send_button_click(@reply.next_button)
    expected = '*Вопрос*: Вопрос со звёздочкой'
    assert_equal(expected, @reply.message, 'Incorrect message on next button after previous question just asked')
    expected_previous = "*Ответ на предыдущий вопрос*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected_previous, @reply.previous_answer, 'Incorrect message on next button after previous question just asked')
  end

  def test_callback_id_on_next_button
    send_button_click(@reply.next_button)
    assert_equal(@message_id, @reply.callback_id, 'Incorrect callback id on next button')
  end
end