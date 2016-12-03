module Imdb
  class SeriesTop250 < MovieList
    
    def initialize(chart_list_type = "top250")
      @chart_type = (chart_list_type == 'top250') ? 'toptv' : 'tvmeter'
    end
    
    private

    def document
      @document ||= Nokogiri::HTML(open("http://akas.imdb.com/chart/#{@chart_type}"))
    end
  end # Top250
end # Imdb
