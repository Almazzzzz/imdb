module Imdb
  # Represents something on IMDB.com
  class PersonBase
    attr_accessor :id, :url, :name, :gender, :birthdate

    # Initialize a new IMDB movie object with it's IMDB id (as a String)
    #
    #   movie = Imdb::Movie.new("0095016")
    #
    # Imdb::Movie objects are lazy loading, meaning that no HTTP request
    # will be performed when a new object is created. Only when you use an
    # accessor that needs the remote data, a HTTP request is made (once).
    #
    def initialize(imdb_id, name = nil, gender = nil)
      @id = imdb_id
      @url = "http://akas.imdb.com/name/nm#{imdb_id}"
      @name = name.gsub(/"/, '').strip if name
      if gender && gender == 1
        @gender = 1
      elsif gender && gender == 0
        @gender = 0
      end
    end


    private

      # Returns a new Nokogiri document for parsing.
      def document
        @document ||= Nokogiri::HTML(Imdb::Movie.find_by_id(@id))
      end

      def locations_document
        @locations_document ||= Nokogiri::HTML(Imdb::Movie.find_by_id(@id, 'locations'))
      end

      def releaseinfo_document
        @releaseinfo_document ||= Nokogiri::HTML(Imdb::Movie.find_by_id(@id, 'releaseinfo'))
      end

      def fullcredits_document
        @fullcredits_document ||= Nokogiri::HTML(Imdb::Movie.find_by_id(@id, 'fullcredits'))
      end
      
      def criticreviews_document
        @criticreviews_document ||= Nokogiri::HTML(Imdb::Movie.find_by_id(@id, 'criticreviews'))
      end

      def business_document
        @business_document ||= sleep(1) && Nokogiri::HTML(Imdb::Movie.find_by_id(@id, 'business'))
      end

      def main_document
        @main_document ||= sleep(2) && Nokogiri::HTML(Imdb::Movie.find_by_id(@id, ''))
      end
      
      # Use HTTParty to fetch the raw HTML for this movie.
      def self.find_by_id(imdb_id, page = :combined)
        open("http://akas.imdb.com/title/tt#{imdb_id}/#{page}", "Accept-Language" => "en")
      end

      # Convenience method for search
      def self.search(query)
        Imdb::Search.new(query).movies
      end

      def self.top_250
        Imdb::Top250.new.movies
      end

      def sanitize_plot(the_plot)
        the_plot = the_plot.gsub(/add\ssummary|full\ssummary/i, '')
        the_plot = the_plot.gsub(/add\ssynopsis|full\ssynopsis/i, '')
        the_plot = the_plot.gsub(/see|more|\u00BB|\u00A0/i, '')
        the_plot = the_plot.gsub(/\|/i, '')
        the_plot.strip
      end

      def sanitize_release_date(the_release_date)
        the_release_date.gsub(/see|more|\u00BB|\u00A0/i, '').strip
      end

      def currency_to_number(currency)
        currency.to_s.gsub(/[$,]/,'').to_f
      end
  end # Movie
end # Imdb
