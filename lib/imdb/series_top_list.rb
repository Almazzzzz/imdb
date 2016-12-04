module Imdb
  class SeriesTopList < MovieList
    
    def initialize(sort_by = "ranking", count = nil)
      @count = count || 100
      if sort_by == "release_date"
        @sort = "release_date,desc"
      elsif sort_by == "popularity"
        @sort == "moviemeter,asc"
      elsif sort_by == "ranking"
        @sort = "user_rating,desc"
      end
    end
    
    private

    def document
      # @document ||= Nokogiri::HTML(open("http://akas.imdb.com/chart/#{@chart_type}"))
      @document ||= Nokogiri::HTML(open("http://akas.imdb.com/search/title?count=#{@count}&num_votes=500,&title_type=tv_series,mini_series&page=1&view=simple&sort=#{@sort}"))
    end
  end # Top250
end # Imdb
