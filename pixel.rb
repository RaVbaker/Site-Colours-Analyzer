#!/usr/bin/env ruby -wKU

class Pixel
  attr_accessor :r, :g, :b, :o
  HexBase = 16   
  
  def initialize r=0, g=0, b=0, o=0
    @r = r
    @g = g
    @b = b
    @o = o
  end
  
  def self.createFromMagickPixel pixel
    Pixel.new pixel.red, pixel.green, pixel.blue, pixel.opacity
  end
  
  def self.colour_hex tone=0
    hex_colour = tone.to_s(HexBase)
    return '0'+hex_colour if tone < HexBase   
    hex_colour
  end
  
  def to_s                 
    "#"+Pixel.colour_hex(@r)+Pixel.colour_hex(@g)+Pixel.colour_hex(@b)+Pixel.colour_hex(@o)
  end                                                     
end