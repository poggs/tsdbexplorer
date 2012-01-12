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

  before_filter :validate_datetime

  # Display services at a particular location
  
  def index

    redirect_to :action => 'index', :year => Time.now.year, :month => Time.now.month, :day => Time.now.day, :time => Time.now.strftime('%H%M') and return if @datetime.nil?


    # Work out which TIPLOCs we're interested in

    if params[:location].length == 3

      # If a three-character location has been entered, try to find an exact
      # match, and if not, redirect to the search page (unless we're in
      # advanced mode)

      tiplocs = StationName.find_related(params[:location].upcase)
      redirect_to :action => 'search', :term => params[:location] and return if tiplocs.blank? && !advanced_mode?
      @location = tiplocs.first.station_name

    elsif advanced_mode?

      # If we're in advanced mode, try to match on a TIPLOC if the CRS code
      # match didn't work.  If the TIPLOC isn't found, redirect to the
      # search page

      tiplocs = Tiploc.where(:tiploc_code => params[:location].upcase)
      redirect_to :action => 'search', :term => params[:location] and return if tiplocs.blank?
      @location = tiplocs.first.tps_description

    else

      # If we haven't found a match, redirect to the search page

      redirect_to :action => 'search', :term => params[:location] and return

    end


    # Work out the start and end of the time range we're interested in

    early_range = 30.minutes
    late_range = 1.hour

    @range = Hash.new
    @range[:from] = @datetime - early_range
    @range[:to] = @datetime + late_range


    # Limit our search only to relevant TIPLOCs

    @schedule = Location.where([ 'locations.tiploc_code IN (?)', tiplocs.collect(&:tiploc_code) ])


    # Only show passenger services if we are not in advanced mode

    @schedule = @schedule.only_passenger if session[:mode] != 'advanced'


    # Optionally limit the search to trains travelling to a particular location

    @schedule = @schedule.runs_to(params[:to]) if params[:to]


    # Prepare an empty array of schedules which have been activated

    @realtime = Array.new


    # Handle windows which span midnight

    if @range[:from].midnight == @range[:to].midnight

      @schedule = @schedule.runs_on(@datetime.to_s(:yyyymmdd)).calls_between(@range[:from].to_s(:hhmm), @range[:to].to_s(:hhmm))

      @schedule.each do |l|
        @realtime.push l.basic_schedule_uuid if $REDIS.get("ACT:" + l.basic_schedule.train_uid + ":" + @range[:from].to_s(:yyyymmdd).gsub('-', ''))
      end

    else

      @schedule_a = @schedule.runs_on(@range[:from].to_s(:yyyymmdd)).calls_between(@range[:from].to_s(:hhmm), '2359')

      @schedule_a.each do |l|
        @realtime.push l.basic_schedule_uuid if $REDIS.get("ACT:" + l.basic_schedule.train_uid + ":" + @range[:from].to_s(:yyyymmdd).gsub('-', ''))
      end

      @schedule_b = @schedule.runs_on(@range[:to].to_s(:yyyymmdd)).calls_between('0000', @range[:to].to_s(:hhmm))

      @schedule_b.each do |l|
        @realtime.push l.basic_schedule_uuid if $REDIS.get("ACT:" + l.basic_schedule.train_uid + ":" + @range[:from].to_s(:yyyymmdd).gsub('-', ''))
      end

    end

  end


  # Search for a location

  def search

    term = params[:term]

    # Redirect to the main page if we're called without any search parameters

    if term.nil?
      render :json => Array.new and return if request.format.json?
      redirect_to :root and return if request.format.html?
    end

    term.upcase!

    # If we've not been called as JSON, and there an exact match on the CRS code, redirect to the location page

    @root_matches = StationName.where('cate_type != 9')

    @matches = @root_matches.where([ 'crs_code = ?', term ])
    redirect_to :action => 'index', :location => @matches.first.crs_code, :year => params[:year], :month => params[:month], :day => params[:day], :time => params[:time] and return if @matches.length == 1 && request.format.html?


    # Check for a match on station name

    @matches = @root_matches.where([ 'crs_code = ? OR station_name LIKE ?', term, '%' + term + '%' ])
    redirect_to :action => 'index', :location => @matches.first.crs_code, :year => params[:year], :month => params[:month], :day => params[:day], :time => params[:time] and return if @matches.length == 1 && request.format.html?

    respond_to do |format|
      format.json { render :format => :json }
      format.html
    end

  end

end
