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

  def test_second_level_of_tours
    send_message('/start')
    send_message('/tours')
    change_question_to('tour1.xml')
    send_button_click(@reply.tour(0))
    assert_equal('Турнир второй', buttons[1][0].text, 'Second tour text is incorrect')
  end
end