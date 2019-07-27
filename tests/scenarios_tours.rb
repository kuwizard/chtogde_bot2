require_relative 'common'

# encoding: utf-8
class ScenariosToursTest < Test::Unit::TestCase
  include Common

  def setup
    @processor = BotProcessorMock.new
    @chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123', first_name: 'Test', last_name: 'User')
    change_question_to('tour_main.xml')
  end

  def teardown
    send_message('/stop')
  end

  def test_switching_to_tours
    send_message('/start')
    send_message('/tours')
    expected = Constants::SWITCHED_TO_TOURS
    assert_equal(expected, @reply.previous_answer, 'Incorrect message while switching to tours')
  end

  def test_switching_to_tours_then_to_random
    send_message('/start')
    send_message('/tours')
    send_message('/random')
    expected = Constants::SWITCHED_TO_RANDOM
    assert_equal(expected, @reply.message, 'Incorrect message while switching to random after tours')
  end

  def test_switching_to_random_after_start
    send_message('/start')
    send_message('/random')
    expected = Constants::ALREADY_RANDOM
    assert_equal(expected, @reply.message, 'Incorrect message while switching to random after start')
  end

  def test_switching_to_tours_twice
    send_message('/start')
    send_message('/tours')
    send_message('/tours')
    expected = Constants::ALREADY_TOURS
    assert_equal(expected, @reply.previous_answer, 'Incorrect message while switching to tours twice')
  end

  def test_markup_is_correct_after_switching_to_tours
    send_message('/start')
    send_message('/tours')
    buttons = @reply.markup.inline_keyboard
    assert_equal(2, buttons.count, 'Incorrect amount of tours in root')
    assert_equal(1, buttons[0].count, 'First line should contain just 1 button')
    assert_equal(1, buttons[1].count, 'Second line should contain just 1 button')
    assert_equal('Турнир первый', buttons[0][0].text, 'First tour text is incorrect')
    assert_equal('Турнир второй', buttons[1][0].text, 'Second tour text is incorrect')
  end

  def test_level_up_content
    send_message('/start')
    send_message('/tours')
    change_question_to('tour1.xml')
    send_button_click(@reply.button_with_text('Турнир первый'))
    assert_equal('⬆️', @reply.markup.inline_keyboard[0][0].text, 'Level up text is incorrect')
    assert_equal("#{@chat.id}/navigation/level_up", @reply.markup.inline_keyboard[0][0].callback_data, 'Level up callback data is incorrect')
  end

  def test_next_page_button_content
    change_question_to('tour_next_prev.xml')
    send_message('/start')
    send_message('/tours')
    next_button = @reply.markup.inline_keyboard[5][0]
    assert_equal('➡️', next_button.text, 'Next page button text is incorrect')
    assert_equal("#{@chat.id}/navigation/next", next_button.callback_data, 'Next page callback data is incorrect')
  end

  def test_prev_page_button_content
    change_question_to('tour_next_prev.xml')
    send_message('/start')
    send_message('/tours')
    send_button_click(@reply.next_page_button)
    prev_button = @reply.markup.inline_keyboard[5][0]
    assert_equal('⬅️', prev_button.text, 'Prev page text is incorrect')
    assert_equal("#{@chat.id}/navigation/prev", prev_button.callback_data, 'Prev page callback data is incorrect')
  end

  def test_just_one_button_on_first
    change_question_to('tour_next_prev.xml')
    send_message('/start')
    send_message('/tours')
    bottom_buttons = @reply.markup.inline_keyboard[5]
    assert_equal(1, bottom_buttons.count, 'Found more or less than 1 button at tour start')
  end

  def test_two_buttons_on_second
    change_question_to('tour_next_prev.xml')
    send_message('/start')
    send_message('/tours')
    send_button_click(@reply.next_page_button)
    bottom_buttons = @reply.markup.inline_keyboard[5]
    assert_equal(2, bottom_buttons.count, 'Found more or less than 2 buttons after switching to next page')
  end

  def test_next_button_on_second
    change_question_to('tour_next_prev.xml')
    send_message('/start')
    send_message('/tours')
    send_button_click(@reply.next_page_button)
    next_button = @reply.markup.inline_keyboard[5][1]
    assert_equal('➡️', next_button.text, 'Next page button text is incorrect after switching to next page')
  end

  def test_just_one_button_on_third
    change_question_to('tour_next_prev.xml')
    send_message('/start')
    send_message('/tours')
    send_button_click(@reply.next_page_button)
    send_button_click(@reply.next_page_button)
    bottom_buttons = @reply.markup.inline_keyboard[5]
    assert_equal(1, bottom_buttons.count, 'Found more or less than 1 button on third page')
  end

  def test_previous_button_on_third
    change_question_to('tour_next_prev.xml')
    send_message('/start')
    send_message('/tours')
    send_button_click(@reply.next_page_button)
    send_button_click(@reply.next_page_button)
    prev_button = @reply.markup.inline_keyboard[5][0]
    assert_equal('⬅️', prev_button.text, 'Prev page text is incorrect')
    assert_equal("#{@chat.id}/navigation/prev", prev_button.callback_data, 'Prev page callback data is incorrect')
  end
end