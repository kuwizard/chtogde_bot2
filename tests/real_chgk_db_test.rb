require_relative 'common'

# encoding: utf-8
class RealChgkDBTest < Test::Unit::TestCase
  include Common

  def setup
    @chat = Telegram::Bot::Types::Chat.new(type: 'private', id: '123')
  end

  def teardown
    send_message('/stop')
  end

  def test_first
    @processor = BotProcessorMock.new
    send_message('/start')
    send_message('/next')
    assert_match(/\*Вопрос\*: .*/, @reply.message, '')
  end

  def test_repeat
    db = { chat_id: 123, question_id: '1', tour_name: 'okno13.2', asked: 't'}
    @processor = BotProcessorMock.new(db)
    send_message('/repeat')
    assert_equal('*Вопрос*: Предки домашних кур, бАнкивские джунглевые куры, куда меньше своих потомков и поэтому опровергают известную пренебрежительную поговорку. А каким образом?', @reply.message, 'Incorrect question')
  end
end