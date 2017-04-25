module Imdb
  # Represents something on IMDB.com
  class PersonBase
    attr_accessor :id, :url, :name, :gender, :birthdate, :birth_year

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

    # Returns a string containing the URL to the movie poster.
    def poster
      src = document.at("img[@id='name-poster']")['src'] rescue nil
      case src
      when /^(https:.+@@)/
        Regexp.last_match[1] + '.jpg'
      when /^(https:.+?)\.[^\/]+$/
        Regexp.last_match[1] + '.jpg'
      end
    end

    # Returns a string containing the name
    def name(force_refresh = false)
      if @name && !force_refresh
        @name
      else
        # puts "String: #{document.at("h1 span[@itemprop='name']").text}"
        @name = document.at("h1 span[@itemprop='name']").text.strip.imdb_unescape_html rescue nil
        # @title = document.at('h1').inner_html.split('<span').first.strip.imdb_unescape_html rescue nil
      end
    end

    def regnal_number
      #overview-top > h1 > span:nth-child(2)
      document.at("h1 > span:nth-child(2)").text.strip.imdb_unescape_html.delete('()').match(/[A-Z]{1,}/) rescue nil
    end

    def birthdate
      birthdate = document.at("time[@itemprop='birthDate']")['datetime'].strip.imdb_unescape_html rescue nil
      
      if birthdate
        @birth_year = birthdate[0..3].to_i
        @birthdate = birthdate.to_date rescue nil
      else
        return nil
      end
    end

    def deathdate
      deathdate = document.at("time[@itemprop='deathDate']")['datetime'].strip.imdb_unescape_html rescue nil      
    end

    def birth_year
      return @birth_year if @birth_year
      @birth_year = document.at("time[@itemprop='birthDate']")['datetime'].strip.imdb_unescape_html[0..3] rescue nil
    end

    def birth_place
      document.at("#name-born-info a[@href*='/search/name?birth_place']").text.strip.imdb_unescape_html rescue nil
    end

    def nickname
      document.at("#dyk-nickname h4").next_sibling.text.strip.imdb_unescape_html rescue nil
    end
    
    def alternate_names
      document.at("#details-akas").text.gsub(/Alternate Names:/, '').strip.imdb_unescape_html.split("|").map {|s| s.strip }.join(", ") rescue nil
      # Save just first alternate name from this string: Alternate Names: Malcolm I. Barrett | Verbal the Rapper
      # document.at("#details-akas h4").next_sibling.text.strip.imdb_unescape_html rescue nil
    end

    def height
      (document.at("#details-height h4").next_sibling.text.strip.imdb_unescape_html.match(/\d+.\d+/).to_s.to_f * 100).to_i rescue nil
    end

    private

      # Returns a new Nokogiri document for parsing.
      def document
        @document ||= Nokogiri::HTML(Imdb::Person.find_by_id(@id))
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
      def self.find_by_id(imdb_id, page = nil)
        # Remove nm part from imdb_id if it exists
        imdb_id = imdb_id.sub(/^nm/, '')
        open("http://akas.imdb.com/name/nm#{imdb_id}", "Accept-Language" => "en")
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
