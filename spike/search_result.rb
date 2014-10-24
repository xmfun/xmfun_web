require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'json'

class Struct
  def to_map
    map = Hash.new
    self.members.each { |m| map[m] = self[m] }
    map
  end

  def to_json(*a)
    to_map.to_json(*a)
  end
end

class Track < Struct.new(:id, :name, :link,
                         :artist_id, :artist_name, :artist_link,
                         :album_id,  :album_name,  :album_link)
end

class TrackList
  attr_accessor :track_list
  def initialize(track_list)
    @track_list = []
    track_list.each do |tr|
      name_td   = tr.css(".song_name   a[target='_blank']")[0]
      artist_td = tr.css(".song_artist a[target='_blank']")[0]
      album_td  = tr.css(".song_album  a[target='_blank']")[0]
      name, name_link     = name_td['title'], name_td['href']
      id = name_link.split("//").last.split(/(\/|\?)/)[4]

      artist_name, artist_link = artist_td['title'], artist_td['href']
      artist_id = artist_link.split("//").last.split(/(\/|\?)/)[4]

      album_name, album_link   = album_td['title'], album_td['href']
      album_id = album_link.split("//").last.split(/(\/|\?)/)[4]

      @track_list << Track.new(id, name,  name_link,
                               artist_id, artist_name, artist_link,
                               album_id,  album_name,  album_link)
    end
  end
end

class Album < Struct.new(:id, :cover, :name, :link,
                         :artist_id, :artist_name, :artist_link, :rank, :year)
end

class AlbumList
  attr_accessor :album_list
  def initialize(album_list)
    @album_list = []
    album_list.each do |div|
      cover   = div.css(".cover a img")[0]['src']

      album_artist  = div.css(".name")

      album, artist = album_artist.css(".song"), album_artist.css(".singer")

      link, name = album[0]['href'], album[0]['title']
      id = link.split("//").last.split(/(\/|\?)/)[4]

      artist_link, artist_name = artist[0]['href'], artist[0]['title']
      artist_id = artist_link.split("//").last.split(/(\/|\?)/)[4]

      rank  = div.css(".album_rank em").text
      year  = div.css(".year").text

      @album_list << Album.new(id, cover, name, link,
                               artist_id, artist_name, artist_link,
                               rank, year)
    end
  end
end

class Artist < Struct.new(:id, :cover, :name, :link, :region)
end

class ArtistList
  attr_accessor :artist_list
  def initialize(artist_list)
    @artist_list = []
    artist_list.each do |div|
      cover   = div.css(".buddy a img")[0]['src']
      link = div.css(".buddy a")[0]['href']
      id = link.split("//").last.split(/(\/|\?)/)[4]

      name  = div.css(".name .title")[0]["title"]
      region = div.css(".name .singer_region").text

      @artist_list << Artist.new(id, cover, name, link, region)
    end
  end
end

class Collect < Struct.new(:id, :cover, :name, :link)
end

class CollectList
  attr_accessor :collect_list
  def initialize(collect_list)
    @collect_list = []
    collect_list.each do |div|
      info_div = div.css("a.info")[0]
      link, name = info_div['href'], info_div['title']
      id = link.split("//").last.split(/(\/|\?)/)[4]
      cover = info_div.css(".cover img")[0]['src']

      @collect_list << Collect.new(id, cover, name, link)
    end
  end
end

class SearchResult
  attr_accessor :track_list, :album_list, :artist_list, :collect_list

  def initialize(track_list, album_list, artist_list, collect_list)
    @track_list   = TrackList.new(track_list)
    @album_list   = AlbumList.new(album_list)
    @artist_list  = ArtistList.new(artist_list)
    @collect_list = CollectList.new(collect_list)
  end

  def to_json
    json = { track_list:   track_list.track_list,
            album_list:   album_list.album_list,
            artist_list:  artist_list.artist_list,
            collect_list: collect_list.collect_list }
    JSON.pretty_generate(json)
  end
end

class SearchManager

  def self.search(keyword)
    url = "http://www.xiami.com/search?key=#{CGI::escape(keyword)}"
    search_page = Nokogiri::HTML(open(url, "Client-IP" => "220.181.111.168"))

    track_list   = search_page.css(".track_list tr")[1..-1]
    album_list   = search_page.css(".albumBlock_list .album_item100_block")
    artist_list  = search_page.css(".artistBlock_list .artist_item100_block")
    collect_list = search_page.css(".collectBlock_list .collect_item100_block")

    SearchResult.new(track_list, album_list, artist_list, collect_list)
  end
end

search_result = SearchManager.search("旅行")

#a = search_result.to_json
#File.open("json", 'a') do |f| f.write(a) end

#a = JSON.pretty_generate(search_result.track_list.track_list)
#File.open("json", 'a') do |f| f.write(a) end
