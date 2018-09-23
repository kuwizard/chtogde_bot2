module GameMode
  RANDOM = :random
  TOURS = :tours
end

module KbType
  HORIZONTAL = :horizontal
  VERTICAL = :vertical
end

module ReplyType
  NEW = :new
  EDIT = :edit
  DELETE = :delete
end

module Navigation
  NEXT = :next
  PREVIOUS = :previous
  LEVEL_UP = :level_up

  def self.values
    [NEXT, PREVIOUS, LEVEL_UP]
  end
end

module MessageType
  ANSWER = :answer
  TELL = :tell
  NEXT_QUESTION = :next_question
  NAVIGATION = :navigation
end