module Imdb
  class SeriesTop250 < MovieList
    private

    def document
      @document ||= Nokogiri::HTML(open('http://akas.imdb.com/chart/toptv'))
    end
  end # Top250
end # Imdb
