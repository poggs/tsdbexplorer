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

class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :in_maintenance_mode?
  before_filter :convert_url_parameters
  helper_method :advanced_mode?


  # Identify if the site is in maintenance mode, and if so, display a holding page

  def in_maintenance_mode?

    unless request[:controller] == "healthcheck"
      if $REDIS.get('OTT:SYSTEM:MAINT')
        render 'common/maintenance_mode', :status => :service_unavailable, :locals => { :reason => $REDIS.get('OTT:SYSTEM:MAINT') } and return
      end
    end

  end


  # Return true if advanced mode has been selected
  
  def advanced_mode?
    return session[:mode] == 'advanced'
  end


  # Toggle between normal and advanced mode
   
  def toggle_mode
      
    session[:mode] = (session[:mode] == 'advanced' ? 'normal' : 'advanced')
    redirect_to :back
              
  end


  # Convert a date and/or time passed un-RESTfully in the URL in to keys in params[]

  def convert_url_parameters

    @today = Time.now


    # Date parsing

    if params[:date] && !params[:date].blank?
      begin
        @date = Date.parse(params[:date])
        params[:year] = @date.year.to_s
        params[:month] = @date.month.to_s.rjust(2, '0')
        params[:day] = @date.day.to_s.rjust(2, '0')
        params.delete(:date)
        @date_passed = true
      rescue
        render 'common/error', :status => :bad_request, :locals => { :message => "Sorry, we couldn't understand the date you gave." }
      end
    elsif params[:year] && params[:month] && params[:day]
      begin
        @date = Date.parse(params[:year] + "-" + params[:month] + "-" + params[:day])
        @date_passed = true
      rescue
        render 'common/error', :status => :bad_request, :locals => { :message => "Sorry, we couldn't understand the date you gave." }
      end
    else
      @date_passed = false
    end


    # Time parsing

    if params[:time]
      begin
        if params[:time].match(/(\d{2})\:(\d{2})/) || params[:time].match(/(\d{2})\.(\d{2})/)
          Time.parse($1 + ":" + $2)
          @time = Time.parse(@date.to_s + " " + $1 + ":" + $2)
        else
          Time.parse(params[:time][0..1] + ":" + params[:time][2..3])
          @time = Time.parse(@date.to_s + " " + params[:time][0..1] + ":" + params[:time][2..3])
        end
        @time_passed = true
      rescue
        render 'common/error', :status => :bad_request, :locals => { :message => "Sorry, we couldn't understand the time you gave." }
      end
    else
      @time_passed = false
    end


    if @date_passed && @time_passed
      @datetime = Time.parse(@date.to_s(:yyyymmdd) + " " + @time.to_s(:hhmm_colon))
    elsif @date_passed && !@time_passed
      @datetime = Time.parse(@date.to_s(:yyyymmdd) + " " + Time.now.to_s(:hhmm_colon))
    else
      @datetime = @today
    end

  end


  # Return all the TIPLOCs for a specified location.  This may be a TIPLOC, in which case, validate and return the TIPLOC.  It may be a CRS code, in which case, return all the associated TIPLOCs from the MSNF

  def tiplocs_for(loc)

    tiplocs = nil

    # Update the location database if it's empty

    if $REDIS.keys('CRS:*').blank?
      logger.warn "Location cache empty - rebuilding"
      TSDBExplorer::Realtime::cache_location_database
    end

    if loc.length == 3

      # If a three-character location has been entered, try to find an exact
      # match, and if not, redirect to the search page (unless we're in
      # advanced mode)

      tiplocs = $REDIS.lrange('CRS:' + loc.upcase + ':TIPLOCS', 0, -1)
      return nil if tiplocs.blank? && !advanced_mode?
      location_name = $REDIS.hget('CRS:' + loc.upcase, 'description')

    elsif advanced_mode?

      # If we're in advanced mode, try to match on a TIPLOC if the CRS code
      # match didn't work.  If the TIPLOC isn't found, redirect to the
      # search page

      location_detail = $REDIS.hgetall('TIPLOC:' + loc.upcase)
      return if location_detail.blank?

      tiplocs = loc.upcase
      location_name = location_detail['description']

    else

      # We are not in advanced mode and a location has been passed that is
      # not a CRS code - so return nothing.

      return nil

    end

    # If we have an array of TIPLOCs, remove duplicates.
    # TODO: Always return an Array of TIPLOCs

    tiplocs.uniq! if tiplocs.class == Array

    return { :locations => tiplocs, :name => location_name }

  end

end
