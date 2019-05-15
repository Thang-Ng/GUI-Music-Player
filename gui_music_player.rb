require 'rubygems'
require 'gosu'
TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)
ARTWORK_SPACE = 6
TRACK_X = 410
TRACK_Y_INI = 10
TRACK_SPACE = 27
FONT_SIZE = 20

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class Track
  attr_accessor :name, :location, :clicked, :x, :y, :text_width, :displayed

  def initialize
    @x = TRACK_X
    @diplayed = false
  end
end

class Album
  attr_accessor :name, :artist, :artwork_location, :genre, :tracks_number, :tracks, :clicked, :title_clicked, :title_disappears, :artwork

  def initialize
  #  @clicked = false
    @title_clicked = false
    @title_disappears = false
  end
end

class ArtWork
	attr_accessor :bmp, :width, :height, :x, :y, :clicked

	def initialize (file)
		@bmp = Gosu::Image.new(file)
    @width = @bmp.width
    @height = @bmp.height
    #@clicked = false
	end
end

# Put your record definitions here

class MusicPlayerMain < Gosu::Window

	def initialize
	    super WINDOW_WIDTH, WINDOW_HEIGHT
	    self.caption = "Music Player"

		# Reads in an array of albums from a file and then prints all the albums in the
		# array to the terminal
    music_file = File.new("albums_info.txt", "r")
    @albums = read_albums(music_file)
    @artworks = read_artworks (@albums)
    @track_font = Gosu::Font.new(self, Gosu::default_font_name, FONT_SIZE)
	end

  #Functions that are used to read in albums and tracks
  def read_track music_file
    track = Track.new()

    track.name = music_file.gets
    track.location = music_file.gets.chomp

    return track
  end

  def read_tracks music_file, album_tracks_number
    tracks = Array.new()

    album_tracks_number.times do
      track = read_track(music_file)
      tracks << track
    end

    return tracks
  end

  def read_album music_file
    album = Album.new()
    album.name = music_file.gets.chomp
    album.artist = music_file.gets.chomp
    album.artwork_location = music_file.gets.chomp
    album.genre = music_file.gets.to_i
    album_tracks_number = music_file.gets.chomp.to_i
    album.tracks_number = album_tracks_number
    album.tracks = read_tracks(music_file, album_tracks_number)

    return album
  end

  def read_albums music_file
    @number_of_albums = music_file.gets.to_i;
    @albums = Array.new()

    @number_of_albums.times do
        album = read_album(music_file)
        @albums << album
        @empty_line = music_file.gets
    end

    return @albums
  end

  # Draws the artwork on the screen for all the albums
  def read_artworks albums
    i = 0
    x = 0
    y = 0
    artworks = Array.new()
    # = albums.length.to_i - 1
    while i < albums.length do
      artwork = ArtWork.new(albums[i].artwork_location)
      if i%2 == 0 && i > 0
        x = 0
        y += artwork.height + ARTWORK_SPACE
      elsif i%2 == 1
        x += artwork.width + ARTWORK_SPACE
      end
      artwork.x = x
      artwork.y = y
      artworks << artwork
      i += 1
    end


    artworks
  end

  def draw_albums albums
    # complete this code
    artworks = read_artworks(albums)
    artworks.each do |artwork|
      artwork.bmp.draw(artwork.x, artwork.y, ZOrder::UI)
    end
  end

  def draw_buttons
    @pause = Gosu::Image.new("images/pause.jpg")
    @pause.draw(TRACK_X, 500, ZOrder::UI)
    @play = Gosu::Image.new("images/play.jpg")
    @play.draw(TRACK_X + @pause.width + 5, 500, ZOrder::UI)
    @next = Gosu::Image.new("images/next.jpg")
    @next.draw(TRACK_X + @pause.width + 5  + @play.width + 5, 500, ZOrder::UI)
  end

  # Detects if a 'mouse sensitive' area has been clicked on
  # i.e either an album or a track. returns true or false

  def area_clicked(leftX, topY, rightX, bottomY)
     # complete this code
     clicked = false
     if mouse_x >= leftX && mouse_x <= rightX && mouse_y >= topY && mouse_y <= bottomY
         clicked = true
     end

     return clicked
  end


  # Takes a String title and an Integer ypos
  # You may want to use the following:
  def display_track(track, ypos)
  	@track_font.draw_markup(track.name, TRACK_X, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
    track.displayed = true
  end

  def display_tracks album
    i = 0
    y = TRACK_Y_INI
    while i < album.tracks_number
      display_track(album.tracks[i], y)
      i += 1
      y += TRACK_SPACE
    end
  end


  # Takes a track index and an Album and plays the Track from the Album

  def playTrack(track)
  		@song = Gosu::Song.new(track.location)
  		@song.play(false)
  end

# Draw a coloured background using TOP_COLOR and BOTTOM_COLOR

	def draw_background
    Gosu.draw_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, BOTTOM_COLOR, ZOrder::BACKGROUND)
	end

# Not used? Everything depends on mouse actions.

	def update

    #when one artwork or a title is clicked, all titles will disappear
    i = 0
    while i < @albums.length
      if @artworks[i].clicked
        @albums[i].tracks.all? {|track| track.displayed = true}
      elsif @artworks[i].clicked == false
        @albums[i].tracks.all? {|track| track.displayed = false}
      end
    i += 1
    end

    @playing_track = Gosu::Song.current_song
    if @pause_track
      @playing_track.pause
    end

    if @play_track
      @playing_track.play
    end

  end

 # Draws the album images and the track list for the selected album

	def draw
		draw_background
    draw_albums(@albums)
    draw_buttons

    @albums.each do |album|
      if album.tracks.all? {|track| track.displayed == true}
        display_tracks(album)
      end
    end

    if @now_playing != nil
      @track_font.draw_markup("SONG BEING CHOSEN: ", 10, 500, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
      @track_font.draw_markup(@now_playing.to_s, 10, 500 + FONT_SIZE + 10, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
    end

	end

 	def needs_cursor?; true; end

	# If the button area (rectangle) has been clicked on change the background color
	# also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
	# you will learn about inheritance in the OOP unit - for now just accept that
	# these are available and filled with the latest x and y locations of the mouse click.
  def check_artwork_clicked artworks
    #artworks.each do |artwork|
    i = 0
    while i < artworks.length
      artwork = artworks[i]
      artwork.clicked = area_clicked(artwork.x, artwork.y, artwork.x + artwork.width, artwork.y + artwork.height)
      i += 1
    end
  end

  def check_track_clicked album
    i = 0
    y = TRACK_Y_INI
    while i < album.tracks_number
      track = album.tracks[i]
      track_title = @track_font
      track.clicked = area_clicked(TRACK_X, y, TRACK_X + track_title.text_width(track.name, scale_x = 1), y + FONT_SIZE)
      if track.clicked
        @index = i
        playTrack(track)
        @now_playing_track = track
        @now_playing = @now_playing_track.name
      end
      y += TRACK_SPACE
      i += 1
    end
  end

	def button_down(id)
		case id
	    when Gosu::MsLeft
	    	# What should happen here?
        if mouse_x < TRACK_X
          check_artwork_clicked(@artworks)
        end

        if @artworks.any? {|artwork| artwork.clicked}
          i = 0
          while i < @artworks.length
            if @albums[i].tracks.all? {|track| track.displayed}
              check_track_clicked(@albums[i])
              @playing_album_index = i
            end
          i += 1
          end
        end


        if mouse_x > TRACK_X && mouse_x < TRACK_X + @pause.width
          @pause_track = true
        else
          @pause_track = false
        end

        if mouse_x > TRACK_X + @pause.width && mouse_x < TRACK_X + @pause.width + @play.width
          @play_track = true
        else
          @play_track = false
        end

        if mouse_x > TRACK_X + @pause.width + 5  + @play.width + 5 && mouse_x < TRACK_X + @pause.width + 5  + @play.width + 5 + @next.width
          @next_track = true
          #@playing_track.stop
          if @index+1 == @albums[@playing_album_index].tracks_number
            @index = -1
          end
          playTrack(@albums[@playing_album_index].tracks[@index+1])
          @now_playing = @albums[@playing_album_index].tracks[@index+1].name
          @index += 1

        end
  end
end
end
# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0
