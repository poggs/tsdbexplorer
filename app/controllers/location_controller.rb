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

    if params[:location].length == 3
      @location = Tiploc.find_by_crs_code(params[:location].upcase)
    else
      @location = Tiploc.find_by_tiploc_code(params[:location].upcase)
    end

    @related_locations = @location.find_related.collect { |x| x.tiploc_code } unless @location.nil?

    if @location.nil?
      render 'common/error', :status => :not_found, :locals => { :message => "We can't find the location '#{params[:location] || params[:location_text]}'" } and return
    end

    early_range = 30.minutes
    late_range = 1.hour

    @range = Hash.new
    @range[:from] = @datetime - early_range
    @range[:to] = @datetime + late_range

    @schedule = Location.where(:tiploc_code => @related_locations)


    # Only show passenger services if we are not in advanced mode

    @schedule = @schedule.only_passenger if session[:mode] != 'advanced'


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

      redirect_to :action => 'index', :location => term.upcase, :year => params[:year], :month => params[:month], :day => params[:day], :time => params[:time] if @matches.length == 1

    end

  end

end
