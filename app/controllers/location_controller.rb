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

      @schedule = Location.where(:tiploc_code => @location.tiploc_code)

      # Handle windows which span midnight

      if @range[:from].midnight == @range[:to].midnight
        @schedule = @schedule.runs_on(@datetime.to_s(:yyyymmdd)).calls_between(@range[:from].to_s(:hhmm), @range[:to].to_s(:hhmm))
      else
        @schedule_a = @schedule.runs_on(@range[:from].to_s(:yyyymmdd)).calls_between(@range[:from].to_s(:hhmm), '2359')
        @schedule_b = @schedule.runs_on(@range[:to].to_s(:yyyymmdd)).calls_between('0000', @range[:to].to_s(:hhmm))
      end

    end

  end


  # Search for a location

  def search

    term = params[:term] || params[:text]

    redirect_to :controller => 'main', :action => 'index' and return if term.blank?

    matches = Array.new

    unless term.nil?

      if term.length == 3
        conditions = [ 'crs_code = ?', term.upcase ]
      else
        conditions = [ 'tiploc_code LIKE ? OR tps_description LIKE ?', '%' + term.upcase + '%', '%' + term.upcase + '%' ]
      end

      @matches = Tiploc.find(:all, :conditions => conditions, :limit => 25)

    end

  end

end
