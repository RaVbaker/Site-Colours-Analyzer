#!/usr/bin/env ruby -wKU

require 'rubygems'
require 'RMagick'

class Image 
  
  attr_reader :width, :height
  
  def initialize file_name
    @image = Magick::Image::read(file_name).first    
    @width = @image.columns
    @height = @image.rows
    @file_name = file_name
  end
  
  def pixels
    @pixels = @image.get_pixels 0, 0, @width, @height if @pixels.nil?
    @pixels
  end
 
  def pixels_hash
    return @pixels_hash unless @pixels_hash.nil?
    
    @pixels_hash = {}  
    
    pixels.each do |pixel|
      one_pixel = Pixel.createFromMagickPixel pixel
      
      pixels_count = 1 + @pixels_hash[one_pixel.to_s][:count] unless @pixels_hash[one_pixel.to_s].nil?
      
      @pixels_hash[one_pixel.to_s] = {
        :sym => one_pixel.to_s,
        :obj => one_pixel,
        :count => pixels_count || 1
      }                                              
   end
   
   @pixels_hash.each do |sym, pix| 
     pix[:popularity] = pix[:count].to_f/pixels_count
   end
   
   @pixels_hash
  end          
  
  def get_pixels_by_most_popular limit=-1
    pixels_hash.sort_by { |p| p[1][:popularity] }.reverse[0..limit]
  end           
  
  def pixels_count
    pixels.size
  end
  
  def colours_count
    pixels_hash.size
  end             
  
  def size
    {:width => @width, :height => @height}
  end
end