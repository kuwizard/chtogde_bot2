require_relative 'common'

# encoding: utf-8
class ScenariosWithTextTest < Test::Unit::TestCase
  include Common

  def setup
    @processor = BotProcessorMock.new
    @chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123', first_name: 'Test', last_name: 'User')
    change_question_to('two_questions_no_pass_criteria.xml')
  end

  def teardown
    send_message('/stop')
  end

  def test_sources_without_starting
    send_message('/sources')
    assert_equal(Constants::NOT_STARTED, @reply.message, 'Incorrect reaction on /sources before starting')
  end

  def test_sources_after_starting
    send_message('/start')
    send_message('/sources')
    assert_equal(Constants::SOURCES_NOW_ON, @reply.message, 'Incorrect reaction on /sources after starting')
  end

  def test_sources_on_and_off_after_starting
    send_message('/start')
    send_message('/sources')
    send_message('/sources')
    assert_equal(Constants::SOURCES_NOW_OFF, @reply.message, 'Incorrect reaction on double /sources after starting')
  end

  def test_sources_on_and_off_and_on_again_after_starting
    send_message('/start')
    send_message('/sources')
    send_message('/sources')
    send_message('/sources')
    assert_equal(Constants::SOURCES_NOW_ON, @reply.message, 'Incorrect reaction on triple /sources after starting')
  end

  def test_sources_after_surrender_if_switching_just_after_start
    send_message('/start')
    send_message('/sources')
    send_message('/next')
    send_message('/answer')
    expected = "*Ответ*: Быть\n*Комментарий*: Замечательный комментарий.\n*Источники*:\nhttp://www.bbb.ru/xxx.htm\nЕщё один источник"
    assert_equal(expected, @reply.message, 'Incorrect sources after surrender if switching on just after start')
  end

  def test_sources_after_surrender_if_switching_after_asking
    send_message('/start')
    send_message('/next')
    send_message('/sources')
    send_message('/answer')
    expected = "*Ответ*: Быть\n*Комментарий*: Замечательный комментарий.\n*Источники*:\nhttp://www.bbb.ru/xxx.htm\nЕщё один источник"
    assert_equal(expected, @reply.message, 'Incorrect sources after surrender if switching on after asking')
  end

  def test_sources_after_correct_answer
    send_message('/start')
    send_message('/next')
    send_message('/sources')
    send_message('/быть')
    expected = "*быть* - это правильный ответ!\n*Комментарий*: Замечательный комментарий.\n*Источники*:\nhttp://www.bbb.ru/xxx.htm\nЕщё один источник"
    assert_equal(expected, @reply.message, 'Incorrect sources in correct answer')
  end

  def test_no_sources_after_switching_them_on_and_off
    send_message('/start')
    send_message('/next')
    send_message('/sources')
    send_message('/next')
    send_message('/sources')
    send_message('/бальзам')
    assert_not_match(/\*Источники\*:/, @reply.message, 'No sources expected after switching them on and off again')
  end

  def test_sources_after_next
    send_message('/start')
    send_message('/next')
    send_message('/sources')
    send_message('/next')
    expected = "*Ответ на предыдущий вопрос*: Быть\n*Комментарий*: Замечательный комментарий.\n*Источники*:\nhttp://www.bbb.ru/xxx.htm\nЕщё один источник"
    assert_equal(expected, @reply.previous_answer, 'Incorrect previous answer with sources')
  end

  def test_no_sources
    change_question_to('question_no_sources.xml')
    send_message('/start')
    send_message('/next')
    send_message('/sources')
    send_message('/answer')
    expected = "*Ответ*: Быть\n*Комментарий*: Замечательный комментарий.\n*Источники*: не указаны"
    assert_equal(expected, @reply.message, 'Incorrect message while no sources were in a question')
  end
end