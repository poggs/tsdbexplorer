#
#  This file is part of TSDBExplorer.
#
#  TSDBExplorer is free software: you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
#
#  TSDBExplorer is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
#  Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with TSDBExplorer.  If not, see <http://www.gnu.org/licenses/>.
#
#  $Id$
#

class LocationController < ApplicationController

  # Display services at a particular location
  
  def index

    if params[:location].length == 3
      @location = Tiploc.find_by_crs_code(params[:location].upcase)
    else
      @location = Tiploc.find_by_tiploc_code(params[:location].upcase)
    end

    if @location.nil?
      render 'common/error', :status => :not_found, :locals => { :message => "We can't find the location '#{params[:location] || params[:location_text]}'" } and return
    else

      @datetime = Time.now

      if params[:date] && params[:time]
        begin
          test_time = Time.parse(params[:time])  # Test the time, otherwise it'll just be replaced with 00:00:00
          @datetime = Time.parse(params[:date] + " " + params[:time])
        rescue
          render 'common/error', :status => :bad_request, :locals => { :message => "We can't understand the date #{params[:date]}, or the time #{params[:time]}" } and return
          exit
        end
      elsif params[:date]
        begin
          test_date = Date.parse(params[:date])  # Test the date, otherwise it'll just be replaced with today
          @datetime = Time.parse(params[:date] + " " + Time.now.strftime("%H:%M:%S"))
        rescue
          render 'common/error', :status => :bad_request, :locals => { :message => "We can't understand the date #{params[:date]}" } and return
        end
      end

      early_range = 30.minutes
      late_range = 1.hour

      @range = Hash.new
      @range[:from] = @datetime - early_range
      @range[:to] = @datetime + late_range

      @schedule = Location.where(:tiploc_code => @location.tiploc_code).runs_on(@datetime.to_s(:iso))

      if advanced_mode?
        @schedule = @schedule.passes_between(@range[:from].strftime('%H%M'), @range[:to].strftime('%H%M'))
      else
        @schedule = @schedule.between(@range[:from].strftime('%H%M'), @range[:to].strftime('%H%M')).only_passenger
      end

      render

    end

  end


  # Search for a location

  def search

    matches = Array.new

    if params[:text].length == 3
      conditions = [ 'crs_code = ?', params[:text].upcase ]
    else
      conditions = [ 'tiploc_code LIKE ? OR tps_description LIKE ?', '%' + params[:text].upcase + '%', '%' + params[:text].upcase + '%' ]
    end

    @matches = Tiploc.find(:all, :conditions => conditions, :limit => 25) #.collect { |m| { :id => m.tiploc_code, :label => m.tps_description + " (" + (m.crs_code.blank? ? m.tiploc_code : m.crs_code) + ")", :value => m.tiploc_code } }

    if matches.length == 1
      redirect_to :action => 'index', :location => @matches.first[:crs_code], :date => params[:date], :time => params[:time] and return
    end

  end

end
