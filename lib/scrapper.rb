class Scrapper

  attr_reader :document

  def initialize(html)
    @document = Hpricot(html)
  end

  def to_theaters
    (document/".theater").map { | element | Theater.new(element) }
  end

  class Theater
    attr_reader :name, :address, :times
    def initialize(element)
      @name     = (element/".name a").text
      @address  = (element/".address").text
      @times    = (element/".times").text
    end
  end
end
