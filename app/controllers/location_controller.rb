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

    loc = params[:location]

    redirect_to root_url and return if loc.nil?

    # Find a list of TIPLOCs for this location

    tiplocs = Array.new

    if loc.length == 3  # It must be a CRS code
      loc.upcase!
      tiplocs = $REDIS.smembers("CRS:TO-TIPLOC:#{loc}")
      @location_name = $REDIS.get("CRS:TO-NAME:#{loc}")
    else
      loc.upcase!
      tiploc_detail = $REDIS.hgetall("TIPLOC:#{loc}")
      unless tiploc_detail.empty?
        tiplocs = [loc]
        @location_name = tiploc_detail['full_name']
      end
    end


    # The TIPLOC or CRS code may not be valid - if so, redirect to a search page

    render 'common/error', :status => :not_found, :locals => { :message => "We couldn't find the location #{loc}" } and return if tiplocs.empty?


    # Determine the location name for the view

    @all_schedules = Array.new


    # Limit the search to a particular location

    @schedule = Location.where(:tiploc_code => tiplocs)


    # Only display passenger schedules in normal mode

    @schedule = @schedule.only_passenger unless advanced_mode?


    # Optionally limit the search to trains travelling to or from a particular location

    unless params[:from].blank?
      from_tiplocs = tiplocs_for(params[:from])
      render 'common/error', :status => :bad_request, :locals => { :message => "We couldn't find the location " + params[:from] + " that you specified in your 'from location' filter." } and return if from_tiplocs.nil? || from_tiplocs[:locations].nil?
      @from_location = from_tiplocs[:name]
      @schedule = @schedule.runs_from(tiplocs_for(params[:from])[:locations])
    end

    unless params[:to].blank?
      to_tiplocs = tiplocs_for(params[:to])
      render 'common/error', :status => :bad_request, :locals => { :message => "We couldn't find the location " + params[:to] + " that you specified in your 'to location' filter." } and return if to_tiplocs.nil? || to_tiplocs[:locations].nil?
      @to_location = to_tiplocs[:name]
      @schedule = @schedule.runs_to(tiplocs_for(params[:to])[:locations])
    end


    # Work out the start and end of the time range we're interested in

    early_range = 30.minutes
    late_range = 1.hour

    @range = Hash.new
    @range[:from] = @datetime - early_range
    @range[:to] = @datetime + late_range


    # Finally, run the query for schedules valid in the time window

    @schedule = @schedule.runs_between(@range[:from], @range[:to], advanced_mode?)

  end


  # Search for a location

  def search

    term = params[:term]
    normalised_term = TSDBExplorer.strip_and_upcase(term)

    matches = Array.new

    if advanced_mode?

      if term.nil? || term.blank? || term.length < 3

        render :json => Array.new and return if request.format.json?
        redirect_to :root and return if request.format.html?

      elsif term.length == 3

        matches = matches + crs_match(term)

        # If called as HTML and there's only one match on the CRS code, redirect to the location page

        redirect_to :controller => 'location', :action => 'index', :location => term and return if request.format.html? && matches.count == 1

      else

        # First, exact-match on TIPLOC code

        matches = matches + tiploc_match(term)


        # If called as HTML and there's only one match on the TIPLOC, redirect to the location page

        redirect_to :controller => 'location', :action => 'index', :location => term and return if request.format.html? && matches.count == 1


        # Partial-match on the CRS and TIPLOC names

        matches = matches + crs_partial_on_name(term)
        matches = matches + tiploc_partial_on_name(term)


        # Finally, fuzzy-match on location name

        matches = matches + tiploc_fuzzy_match(term)

      end

    else

      if term.nil? || term.blank? || term.length < 3

        render :json => Array.new and return if request.format.json?
        redirect_to :root and return if request.format.html?

      elsif term.length == 3

        matches = matches + crs_match(term)

        # If called as HTML and there's only one match on the CRS code, redirect to the location page

        redirect_to :controller => 'location', :action => 'index', :location => term and return if request.format.html? && matches.count == 1

      else

        # First, exact-match on CRS code.  Redirect if called as HTML and there's exactly one match

        matches = matches + crs_match(term)
        redirect_to :controller => 'location', :action => 'index', :location => term and return if request.format.html? && matches.count == 1


        # Next, partial-match on CRS code station names.  Redirect with exact logic if there's exactly one match

        matches = matches + crs_partial_on_name(term)

        redirect_to :controller => 'location', :action => 'index', :location => matches.first['id'] and return if request.format.html? && matches.count == 1


        # Finally, fuzzy-match on CRS code station name

        matches = matches + crs_fuzzy_match(term)

      end

    end


    match_ids = Array.new
    @matches = Array.new

    matches.each do |m|
      next if match_ids.include? m['id']
      match_ids.push m['id']
      @matches.push m
    end

    respond_to do |format|
      format.json { render :json => @matches.to_json }
      format.html
    end

  end

  private

  def crs_partial_on_name(term)

    matches = Array.new
    normalised_term = TSDBExplorer.strip_and_upcase(term)

    crs_text_match = $REDIS.keys("NAME:TO-CRS:*#{normalised_term}*")

    crs_text_match.each do |loc|
      crs_code = $REDIS.get(loc)
      crs_text = $REDIS.get("CRS:TO-NAME:#{crs_code}")
      matches.push({ 'id' => crs_code, 'label' => "#{crs_text} [#{crs_code}]", 'value' => crs_code })
    end

    return matches

  end


  def tiploc_partial_on_name(term)

    matches = Array.new
    normalised_term = TSDBExplorer.strip_and_upcase(term)

    tiploc_text_match = $REDIS.keys("NAME:TO-TIPLOC:*#{normalised_term}*")

    tiploc_text_match.each do |loc|
      tiploc = $REDIS.get(loc)
      tiploc_text = $REDIS.hget("TIPLOC:#{tiploc}", "full_name")
      matches.push({ 'id' => tiploc, 'label' => "#{tiploc_text} [#{tiploc}]", 'value' => tiploc })
    end

    return matches

  end


  def tiploc_match(term)

    matches = Array.new
    normalised_term = TSDBExplorer.strip_and_upcase(term)

    tiploc_exact_match = $REDIS.hget("TIPLOC:#{normalised_term}", "full_name")

    matches.push({ 'id' => term.upcase, 'label' => tiploc_exact_match + " [#{term.upcase}]", 'value' => term.upcase }) unless tiploc_exact_match.nil?

    return matches

  end

  def crs_match(term)

    matches = Array.new

    term.upcase!
    crs_exact_match = $REDIS.get("CRS:TO-NAME:#{term}")

    matches.push({ 'id' => term, 'label' => "#{crs_exact_match} [#{term}]", 'value' => term }) unless crs_exact_match.nil?

    return matches

  end

  def tiploc_fuzzy_match(term)

    matches = Array.new
    tiploc_text_match = Array.new

    term.split(' ').each do |e|
      m = $REDIS.smembers("FUZZY-NAME:TO-TIPLOC:#{Text::Metaphone.metaphone(e)}")
      tiploc_text_match = tiploc_text_match.blank? ? m : tiploc_text_match & m
    end

    tiploc_text_match.collect { |loc| matches.push({ 'id' => loc, 'label' => "#{$REDIS.hget('TIPLOC:' + loc, 'full_name')} [#{loc}]", 'value' => loc }) } unless tiploc_text_match.nil?

    return matches

  end

  def crs_fuzzy_match(term)

    matches = Array.new
    crs_text_match = Array.new

    term.split(' ').each do |e|
      m = $REDIS.smembers("FUZZY-NAME:TO-CRS:#{Text::Metaphone.metaphone(e)}")
      crs_text_match = crs_text_match.blank? ? m : crs_text_match & m
    end

    crs_text_match.collect { |loc| matches.push({ 'id' => loc, 'label' => "#{$REDIS.get('CRS:TO-NAME:' + loc)} [#{loc}]", 'value' => loc }) } unless crs_text_match.nil?

    return matches

  end

end
