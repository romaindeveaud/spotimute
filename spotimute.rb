#!/usr/bin/ruby1.8

require 'gtk2'

Debug = ARGV.empty? ? false : ( ARGV[0] == "-d" ? true : false )


@screen = Gdk::Screen.default
@window_title = ""

@adlist = File.open('adlist.txt','a+').readlines.collect { |l| l.chomp }

def gdk_windows
  @screen.window_stack
end

def is_spotify_running?
  gdk_windows.collect { |w| `xwininfo -id #{w.xid}`.split("\"")[1] }.each { |w| return true if w =~ /Spotify.*/ }
  return false
end

def mute
  `amixer -c 1 sset Master,0 mute`
end

def unmute
  `amixer -c 1 sset Master,0 unmute`
end

def window_name_changed
  if @adlist.include?(@window_title)
    puts "[ad]   #{@window_title}"
    mute
  else
    puts "[song] #{@window_title}"
    unmute
  end
end

def check_title
  gdk_windows.each do |w|
    title = `xwininfo -id #{w.xid}`.split("\"")[1]
    if title =~ /^Spotify.*$/ && @window_title != title
      @window_title = title
      window_name_changed
    end
  end
end

def keyboard_handle
  while l = $stdin.gets
    if l.chomp == "add"
      File.open('adlist.txt','a+').puts @window_title
      puts @window_title+" successfully added to ad list." 
    end
  end
end

def main
  while (Gtk.events_pending?)
    Gtk.main_iteration
  end

  unless is_spotify_running?
    puts "Spotify window not found.\nOpen the Spotify window."
    exit
  end

  t = Thread.new { keyboard_handle }

# TODO: 
# Implement a real event handler !!
#
# Ideally, there would be an event handler for some window-title-change events,
# but I didn't manage to do this on Gdk Windows, feel free to contribute !
#
#
# TODO:
# sleep less than 1 second, without taking to much CPU. 
  while true
    check_title
    sleep 1
  end
end

if __FILE__ == $0
  main
end
