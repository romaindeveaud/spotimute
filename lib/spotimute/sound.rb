#!/usr/bin/env ruby

module Spotimute

  class Sound
    attr_reader   :mixer, :card
    attr_accessor :volume, :muted

    def self.mixers
      `amixer scontrols`.split("\n").collect { |l| l.strip.split.last.gsub(/'/,'') if l =~ /^\w/ }.compact
    end

    def self.cards
      `amixer info` .split("\n").collect { |l| l.strip.split.last.gsub(/'/,'') if l =~ /^\w/ }.compact
    end
    
    def initialize(mix="Master,0", card=1)
      @mixer = mix
      @card  = card
    end
    
    def mute
      `amixer -c #{@card} sset #{@mixer} mute`
    end

    def unmute
      `amixer -c #{@card} sset #{@mixer} unmute`
    end

  end

end
