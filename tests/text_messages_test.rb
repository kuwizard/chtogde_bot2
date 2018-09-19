require_relative 'common'

# encoding: utf-8
class TextMessagesTest < Test::Unit::TestCase
  include Constants
  include Common

  def setup
    @processor = BotProcessorMock.new
    @chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123', first_name: 'Test', last_name: 'User')
    change_question_to('two_questions_no_pass_criteria.xml')
  end

  def teardown
    send_message('/stop')
  end

  def test_start
    send_message('/start')
    assert_equal(Constants::START, @reply.message, 'Incorrect message just after start')
  end

  def test_stop_without_start
    send_message('/stop')
    assert_equal(Constants::STOP, @reply.message, 'Incorrect message on /stop without start')
  end

  def test_help_without_start
    send_message('/help')
    assert_equal(Constants::HELP, @reply.message, 'Incorrect message on /help without start')
  end

  def test_next_without_start
    send_message('/next')
    assert_equal(Constants::NOT_STARTED, @reply.message, 'Incorrect message on /next without start')
  end

  def test_answer_without_start
    send_message('/answer')
    assert_equal(Constants::NOT_STARTED, @reply.message, 'Incorrect message on /answer without start')
  end

  def test_repeat_without_start
    send_message('/repeat')
    assert_equal(Constants::NOT_STARTED, @reply.message, 'Incorrect message on /repeat without start')
  end

  def test_sometext_without_start
    send_message('/фигня')
    assert_equal(Constants::NOT_STARTED, @reply.message, 'Incorrect message on sometext without start')
  end

  def test_stop_after_start_and_stop
    send_message('/start')
    send_message('/stop')
    send_message('/stop')
    assert_equal(Constants::STOP, @reply.message, 'Incorrect message on stop after start and stop')
  end

  def test_start_after_start_and_stop
    send_message('/start')
    send_message('/stop')
    send_message('/start')
    assert_equal(Constants::START, @reply.message, 'Incorrect message on /start after start and stop')
  end

  def test_help_after_start_and_stop
    send_message('/start')
    send_message('/stop')
    send_message('/help')
    assert_equal(Constants::HELP, @reply.message, 'Incorrect message on /help after start and stop')
  end

  def test_next_after_start_and_stop
    send_message('/start')
    send_message('/stop')
    send_message('/next')
    assert_equal(Constants::NOT_STARTED, @reply.message, 'Incorrect message on /next after start and stop')
  end

  def test_answer_after_start_and_stop
    send_message('/start')
    send_message('/stop')
    send_message('/answer')
    assert_equal(Constants::NOT_STARTED, @reply.message, 'Incorrect message on /answer after start and stop')
  end

  def test_repeat_after_start_and_stop
    send_message('/start')
    send_message('/stop')
    send_message('/repeat')
    assert_equal(Constants::NOT_STARTED, @reply.message, 'Incorrect message on /repeat after start and stop')
  end

  def test_sometext_after_start_and_stop
    send_message('/start')
    send_message('/stop')
    send_message('/фигня')
    assert_equal(Constants::NOT_STARTED, @reply.message, 'Incorrect message on sometext after start and stop')
  end

  def test_answer_after_start
    send_message('/start')
    send_message('/answer')
    assert_equal(Constants::STARTED_NOT_ASKED, @reply.message, 'Incorrect message on /answer after start')
  end

  def test_repeat_after_start
    send_message('/start')
    send_message('/repeat')
    assert_equal(Constants::STARTED_NOT_ASKED, @reply.message, 'Incorrect message on /repeat after start and stop')
  end

  def test_sometext_after_start
    send_message('/start')
    send_message('/фигня')
    assert_equal(Constants::STARTED_NOT_ASKED, @reply.message, 'Incorrect message on sometext after start and stop')
  end

  def test_help_after_start
    send_message('/start')
    send_message('/help')
    assert_equal(Constants::HELP, @reply.message, 'Incorrect message on /help after start and stop')
  end

  def test_next_after_start
    send_message('/start')
    send_message('/next')
    expected = '*Вопрос*: Быть или не быть?'
    assert_equal(expected, @reply.message, 'Incorrect message on next after start')
  end

  def test_markup_not_nil_after_next
    send_message('/start')
    send_message('/next')
    assert_not_nil(@reply.markup, 'Markup should not be nil in a question')
  end

  def test_help_after_asked
    send_message('/start')
    send_message('/next')
    send_message('/help')
    assert_not_nil(Constants::HELP, 'Incorrect message on /help after start and next')
  end

  def test_markup_is_of_correct_class
    send_message('/start')
    send_message('/next')
    assert_instance_of(Telegram::Bot::Types::InlineKeyboardMarkup, @reply.markup, 'Incorrect class of markup')
  end

  def test_keyboard_has_2_buttons
    send_message('/start')
    send_message('/next')
    assert_equal(2, @reply.markup.inline_keyboard[0].count, 'Incorrect count of buttons in keyboard')
  end

  def test_answer_button
    send_message('/start')
    send_message('/next')
    answer_button = @reply.answer_button
    assert_instance_of(Telegram::Bot::Types::InlineKeyboardButton, answer_button, 'Incorrect class of answer button')
    assert_equal("#{@chat.id}/answer", answer_button.callback_data, 'Incorrect callback data on answer button')
    assert_equal('Ответ', answer_button.text, 'Incorrect text on answer button')
  end

  def test_next_button
    send_message('/start')
    send_message('/next')
    next_button = @reply.next_button
    assert_instance_of(Telegram::Bot::Types::InlineKeyboardButton, next_button, 'Incorrect class of next button')
    assert_equal("#{@chat.id}/next_question", next_button.callback_data, 'Incorrect callback data on next button')
    assert_equal('Следующий', next_button.text, 'Incorrect text on next button')
  end

  def test_send_nothing
    send_message('')
    assert_nil(@reply, '@reply is not nil after sending nothing')
  end

  def test_send_slash
    send_message('/')
    assert_equal(Constants::NOT_STARTED, @reply.message, 'Incorrect reaction on slash')
  end
end