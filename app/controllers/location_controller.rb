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

  include ApplicationHelper

  # Display services at a particular location
  
  def index

    redirect_to root_url and return if params[:location].nil?

    tiplocs = tiplocs_for(params[:location])
    redirect_to :action => 'search', :term => params[:location] and return if tiplocs.nil?


    # Determine the name of this location

    @location = tiplocs[:name]


    # Work out the start and end of the time range we're interested in

    early_range = 30.minutes
    late_range = 1.hour

    @range = Hash.new
    @range[:from] = @datetime - early_range
    @range[:to] = @datetime + late_range


    # Limit our search only to relevant TIPLOCs

    @schedule = Location.where([ 'locations.tiploc_code IN (?)', tiplocs[:locations].collect(&:tiploc_code) ])


    # Only show passenger services if we are not in advanced mode

    @schedule = @schedule.only_passenger if session[:mode] != 'advanced'


    # Optionally limit the search to trains travelling to or from a particular location

    unless params[:from].blank?
      from_tiplocs = tiplocs_for(params[:from])
      render 'common/error', :status => :bad_request, :locals => { :message => "We couldn't find the location " + params[:from] + " that you specified in your 'from location' filter." } and return if from_tiplocs.nil? || from_tiplocs[:locations].nil?
      @from_location = from_tiplocs[:name]
      @schedule = @schedule.runs_from(tiplocs_for(params[:from])[:locations].collect(&:tiploc_code))
    end

    unless params[:to].blank?
      to_tiplocs = tiplocs_for(params[:to])
      render 'common/error', :status => :bad_request, :locals => { :message => "We couldn't find the location " + params[:to] + " that you specified in your 'to location' filter." } and return if to_tiplocs.nil? || to_tiplocs[:locations].nil?
      @to_location = to_tiplocs[:name]
      @schedule = @schedule.runs_to(tiplocs_for(params[:to])[:locations].collect(&:tiploc_code))
    end


    # Prepare an empty array of schedules which have been activated

    @realtime = Array.new


    # Handle windows which span midnight

    if @range[:from].midnight == @range[:to].midnight

      @schedule = @schedule.runs_on(@datetime.to_s(:yyyymmdd)).calls_between(@range[:from].to_s(:hhmm), @range[:to].to_s(:hhmm))

      @schedule.each do |l|
        next if l.basic_schedule.nil?
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

    @matches = Array.new


    # Try an exact match on the CRS code if the term is three characters long

    @matches = match_msnf_on_crs(term) if term.length == 3


    # If we've been called as HTML and there's exactly one match, redirect to the location page

    redirect_to :action => 'index', :location => @matches.first.crs_code, :from => params[:from], :to => params[:to], :year => params[:year], :month => params[:month], :day => params[:day], :time => params[:time] and return if @matches.length == 1 && request.format.html?


    if advanced_mode?

      # Try an exact match on the TIPLOC code

      @matches = @matches + match_cif_on_tiploc(term) if term.length > 3
      redirect_to :action => 'index', :location => @matches.first.tiploc_code, :from => params[:from], :to => params[:to], :year => params[:year], :month => params[:month], :day => params[:day], :time => params[:time] and return if @matches.length == 1 && request.format.html?

    end


    # Check for a match on station name.

    @matches = @matches + match_msnf_on_station_name(term)


    # If we've been called as HTML and there's exactly one match, redirect to the location page

    redirect_to :action => 'index', :location => @matches.first.crs_code, :from => params[:from], :to => params[:to], :year => params[:year], :month => params[:month], :day => params[:day], :time => params[:time] and return if @matches.length == 1 && request.format.html?


    if advanced_mode?

      # Check for a match on TPS description in the CIF data

      @matches = @matches + match_cif_on_description(term)
      redirect_to :action => 'index', :location => @matches.first.tiploc_code, :from => params[:from], :to => params[:to], :year => params[:year], :month => params[:month], :day => params[:day], :time => params[:time] and return if @matches.length == 1 && request.format.html?

    end

    respond_to do |format|
      format.json { render :json => matches_to_json(@matches) }
      format.html
    end

  end

  private

  # Convert matches to JSON format

  def matches_to_json(matches)

    @json_matches = Array.new

    matches.each do |m|
      @json_matches.push(convert_match_to_json(m))
    end

    return @json_matches

  end


  # Convert a single match to JSON

  def convert_match_to_json(match)

    if match.is_a? StationName
      id = match.crs_code
      text = tidy_text(match.station_name)
    elsif match.is_a? Tiploc
      id = match.tiploc_code
      text = tidy_text(match.tps_description)
    end

    text = text + ' (' + id + ')'

    { :id => id, :label => text, :value => id }

  end


  # Try to match a CRS code against the MSNF

  def match_msnf_on_crs(term)

    StationName.where('cate_type != 9 AND crs_code = ?', term)

  end


  # Try to match a station name against the MSNF

  def match_msnf_on_station_name(term)

    StationName.where('cate_type != 9 AND station_name LIKE ?', '%' + term + '%')

  end


  # Try to match a TIPLOC code against the CIF data

  def match_cif_on_tiploc(term)

    Tiploc.where('tiploc_code = ?', term)

  end


  # Try to match a location description against the CIF data

  def match_cif_on_description(term)

    Tiploc.where('tps_description LIKE ?', '%' + term + '%')

  end


  # Return all the TIPLOCs for a specified location.  This may be a TIPLOC, in which case, validate and return the TIPLOC.  It may be a CRS code, in which case, return all the associated TIPLOCs from the MSNF

  def tiplocs_for(loc)

    tiplocs = nil

    if loc.length == 3

      # If a three-character location has been entered, try to find an exact
      # match, and if not, redirect to the search page (unless we're in
      # advanced mode)

      tiplocs = StationName.find_related(loc.upcase)
      return nil if tiplocs.blank? && !advanced_mode?
      location_name = StationName.find_by_crs_code(loc.upcase).station_name

    elsif advanced_mode?

      # If we're in advanced mode, try to match on a TIPLOC if the CRS code
      # match didn't work.  If the TIPLOC isn't found, redirect to the
      # search page

      tiplocs = Tiploc.where(:tiploc_code => loc.upcase)
      return nil if tiplocs.blank?
      location_name = Tiploc.find_by_tiploc_code(loc.upcase).tps_description

    else

      # We are not in advanced mode and a location has been passed that is
      # not a CRS code - so return nothing.

      return nil

    end

    return { :locations => tiplocs, :name => location_name }

  end

end
