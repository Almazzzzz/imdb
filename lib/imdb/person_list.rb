module Imdb
  class PersonList

    def initialize(start_from = 1, gender = 'female')
      @start_from = start_from
      @gender = (gender == 'female') ? 'female' : 'male'
      @gender_as_number = (gender == 'female') ? 0 : 1
    end

    def people
      @people ||= parse_people
    end

    private

      def parse_people
        document.search("a[@href^='/name/nm']").reject do |element|
          element.inner_html.imdb_strip_tags.empty? ||
          element.inner_html.imdb_strip_tags == 'X' ||
          element.parent.inner_html =~ /media from/i
        end.map do |element|
          # puts element
          id = element['href'][/\d+/]
          name = element.content

          # data = element.parent.inner_html.split('<br />')
          # name = (!data[0].nil? && !data[1].nil? && data[0] =~ /img/) ? data[1] : data[0]
          # name = name.imdb_strip_tags.imdb_unescape_html
          # name.gsub!(/\s+\(\d\d\d\d\)$/, '')

          # if name =~ /\saka\s/
          #   names = name.split(/\saka\s/)
          #   name = names.shift.strip.imdb_unescape_html
          # end

          !name.strip.blank? ? [id, name, @gender_as_number] : nil
        end.compact.uniq.map do |values|
          # puts values
          Imdb::Person.new(*values)
        end
      end
    
    def document
      # @document ||= Nokogiri::HTML(open("http://akas.imdb.com/chart/#{@chart_type}"))
      @document ||= Nokogiri::HTML(open("http://www.imdb.com/search/name?count=100&gender=#{@gender}&sort=starmeter&start=#{@start_from}"))
    end      
  end # MovieList
end # Imdb
