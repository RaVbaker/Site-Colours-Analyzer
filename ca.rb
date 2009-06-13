#!/usr/bin/env ruby

# SiteColoursAnalyzer
# Author: Rafal "RaVbaker" Piekarski
# Version: 0.1
# more on github: http://github.com/RaVbaker/Site-Colours-Analyzer/tree/master

require 'rubygems'
require 'google_chart'
require 'image.rb'
require 'pixel.rb'
require 'digest/md5'

class SiteColoursAnalyzer

  ImagesPath, ImagePostfix = ['',  '-full.png']   
  attr_reader :page_url
  
  def initialize(page_url)
    @page_url = page_url 
    open_image_file
  end                   
  
  def hashed_screenshot_file 
    ImagesPath+Digest::MD5.hexdigest(@page_url)
  end                                 
  
  def fetch_screenshot
    system("python webkit2png.py -o #{ImagesPath+hashed_screenshot_file} #{@page_url}")
  end
  
  def hashed_page_screenshot_file_name
    hashed_screenshot_file+ImagePostfix
  end
                              
  def generate_pie_chart_url(chart_title, pop_pixs, colours_limit = 30, size = "680x350", is_3d = true)

     url = ""

    GoogleChart::PieChart.new(size, "ColoursGraph from #{chart_title}", is_3d) do |pc|

      pop_pixs[0..colours_limit].each do |pixs|
        sym, pixel_details = pixs
        popularity = (pixel_details[:popularity].to_f*10000).round
        pc.data "#{sym[0..-3]} - #{popularity/100.0} %", popularity/100.0, sym[1..-3]
      end      

      other = (pop_pixs[colours_limit..-1].inject(0) {|sum,p| sum+=p[1][:popularity]}.to_f*10000).round
      pc.data "other/text - #{other/100.0}%", other/100.0, "000000"

      pc.data_encoding = :text
      url = pc.to_url
    end    

    url
  end
  
  def get_pop_pixels
    open_image_file if @img.nil?
    @pop_pixs = @img.get_pixels_by_most_popular if @pop_pixs.nil?
    
    @pop_pixs
  end        
  
  def open_image_file
    fetch_screenshot
    @img = Image.new hashed_page_screenshot_file_name
  end   
  
  def show_chart_url_and_save(chart_title, pop_pixs, output_filename="chart", colours_limit = 30, size = "680x350", is_3d = true)
    
    chart_url = generate_pie_chart_url(chart_title, pop_pixs, colours_limit, size, is_3d)
#p "wget -o '#{ImagesPath+hashed_screenshot_file}-#{output_filename}.png' '#{chart_url}'"
  #  system "wget -o '#{ImagesPath+hashed_screenshot_file}-#{output_filename}.png' '#{chart_url}'"
    chart_url
  end     
  
  def clean_up
    system "rm #{hashed_screenshot_file}*"
  end
end
               
if __FILE__ == $0
  
  analyze = SiteColoursAnalyzer.new(ARGV[0] || "http://ravbaker.net/")
  
  puts
  puts "Link to chart with bg:"
  puts analyze.show_chart_url_and_save(analyze.page_url, analyze.get_pop_pixels)
  puts
  puts "Link to chart without bg:"
  puts analyze.show_chart_url_and_save("without background (#{(analyze.get_pop_pixels.first[1][:popularity]*100).round} %) #{analyze.page_url}", analyze.get_pop_pixels[1..-1], "chart-without-bg", 30, "680x350")
  puts              
  
  analyze.clean_up
end