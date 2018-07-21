require_relative 'common'

# encoding: utf-8
class ScenariosInGroupChatTest < Test::Unit::TestCase
  include Common

  def setup
    @processor = BotProcessorMock.new
    @chat = Telegram::Bot::Types::Chat.new(type: 'group', id: '333', first_name: 'Group', last_name: 'User')
    change_question_to('two_questions_no_pass_criteria.xml')
    send_message('/start')
  end

  def teardown
    send_message('/stop')
  end

  def test_answer_correctly_in_group
    send_message('/next')
    send_message('/быть')
    expected = "*быть* - это правильный ответ!\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, @reply.message, 'Incorrect message on correct answer in group')
    assert_nil(@reply.previous_answer, 'Previous answer is not nil')
  end

  def test_repeat_in_group
    send_message('/next')
    send_message('/repeat')
    expected = '*Вопрос*: Быть или не быть?'
    assert_equal(expected, @reply.message, 'Incorrect message on /repeat after answer in group')
    assert_nil(@reply.previous_answer, 'Previous answer is not nil')
  end

  def test_surrender_in_group
    send_message('/next')
    send_message('/answer')
    expected = "*Ответ*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, @reply.message, 'Incorrect message on /answer in group')
    assert_nil(@reply.previous_answer, 'Previous answer is not nil')
  end

  def test_next_on_asked_in_group
    send_message('/next')
    send_message('/next')
    expected = '*Вопрос*: Вопрос со звёздочкой'
    assert_equal(expected, @reply.message, 'Incorrect message on /next after previous question just asked in group')
    expected_previous = "*Ответ на предыдущий вопрос*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected_previous, @reply.previous_answer, 'Incorrect message on /next after previous question just asked in group')
  end

  def test_three_buttons
    send_message('/next')
    assert_equal(3, @reply.buttons_count, 'Incorrect number of buttons in reply')
  end

  def test_tell_button
    send_message('/next')
    tell_button = @reply.tell_button
    assert_instance_of(Telegram::Bot::Types::InlineKeyboardButton, tell_button, 'Incorrect class of tell button')
    assert_equal("tell#{@chat.id}", tell_button.callback_data, 'Incorrect callback data on tell button')
    assert_equal('В личку', tell_button.text, 'Incorrect text on tell button')
  end

  def test_responses_are_in_group_chat
    assert_equal(@chat.id, @reply.chat_id, 'Incorrect chat id start message was sent to, expected group chat id')
    send_message('/next')
    assert_equal(@chat.id, @reply.chat_id, 'Incorrect chat id next question was sent to, expected group chat id')
  end

  def test_tell_button_sends_answer
    send_message('/next')
    send_button_click(@reply.tell_button)
    expected = "*Ответ*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, @reply.message, 'Incorrect answer was sent to private chat when anyone has cheated')
  end

  def test_tell_button_sends_answer_privately
    send_message('/next')
    send_button_click(@reply.tell_button)
    assert_equal(Users::TEST_USER.id, @reply.chat_id, 'Incorrect chat id next question was sent to, expected private chat id')
  end

  def test_after_tell_bot_still_answers_to_group
    send_message('/next')
    send_button_click(@reply.tell_button)
    send_message('/answer')
    assert_equal(@chat.id, @reply.chat_id, 'Incorrect chat id start message was sent to, expected group chat id')
  end

  def test_others_can_see_comeone_cheated
    send_message('/next')
    send_button_click(@reply.tell_button)
    send_message('/answer')
    expected = "*Ответ (который кое-кто уже подсмотрел)*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, @reply.message, 'Incorrect answer after anyone has cheated')
  end

  def test_remove_bot_from_chat
    remove_bot_from_chat
    assert_nil(@reply, 'Reply is not nil after removing bot from chat')
  end

  def test_add_bot_to_chat
    add_bot_to_chat
    assert_nil(@reply, 'Reply is not nil after adding bot to chat')
  end

  def test_saving_progress_after_deleting_and_adding
    send_message('/next')
    remove_bot_from_chat
    add_bot_to_chat
    send_message('/answer')
    expected = "*Ответ*: Быть\n*Комментарий*: Замечательный комментарий."
    assert_equal(expected, @reply.message, 'Incorrect answer after deleting bot and adding back')
  end
end