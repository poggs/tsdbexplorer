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

  before_filter :calculate_stats
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


  # Calculate statistics to be included in the footer of each page

  def calculate_stats

    @stats = Hash.new
    @stats[:latest_schedule] = BasicSchedule.maximum(:runs_to) unless BasicSchedule.count == 0

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

    @date = Date.today

    if params[:date]
      begin
        @date = Date.parse(params[:date])
        params[:year] = @date.year.to_s
        params[:month] = @date.month.to_s.rjust(2, '0')
        params[:day] = @date.day.to_s.rjust(2, '0')
        params.delete(:date)
      rescue
      end
    end

    if params[:year] && params[:month] && params[:day]
      begin
        @date = Date.parse(params[:year] + "-" + params[:month] + "-" + params[:day])
      rescue
        render 'common/error', :status => :bad_request, :locals => { :message => "Sorry, we couldn't understand the date you gave." }
      end
    end

    if params[:time]
      begin
        if params[:time].blank?
          @time = Time.parse(@date.to_s + " " + Time.now.to_s(:hhmm))
        elsif params[:time].match(/(\d{2})\:(\d{2})/) || params[:time].match(/(\d{2})\.(\d{2})/)
          Time.parse($1 + ":" + $2)
          @time = Time.parse(@date.to_s + " " + $1 + ":" + $2)
        else
          Time.parse(params[:time][0..1] + ":" + params[:time][2..3])
          @time = Time.parse(@date.to_s + " " + params[:time][0..1] + ":" + params[:time][2..3])
        end
      rescue
        render 'common/error', :status => :bad_request, :locals => { :message => "Sorry, we couldn't understand the time you gave." }
      end
    else
      @time = Time.parse(@date.to_s + " " + Time.now.to_s(:hhmm))
      params[:time] = nil
    end

    @datetime = @time

  end

end
