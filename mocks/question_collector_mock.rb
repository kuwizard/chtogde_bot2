class QuestionCollectorMock < QuestionCollector
  attr_reader :file

  def initialize(file = nil)
    @file = file
  end

  private

  def xml
    if @file
      File.open("#{Constants::FILE_PATH}#{@file}") { |f| Nokogiri::XML(f) }
    else
      Nokogiri::XML(open(@url))
    end
  end
end