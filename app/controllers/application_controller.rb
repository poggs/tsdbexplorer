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

    render 'common/maintenance_mode', :status => :service_unavailable, :locals => { :reason => $REDIS.get('OTT:SYSTEM:MAINT') } and return if $REDIS.get('OTT:SYSTEM:MAINT')

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


  # Validate the date and time passed

  def validate_datetime

    if(params[:year] || params[:month] || params[:day] || params[:time])

      begin
        params[:time] = Time.now.strftime('%H%M') if params[:time].nil?
        if params[:time] =~ /\d{4}/
          @datetime = Time.gm(params[:year], params[:month], params[:day], params[:time][0..1], params[:time][2..3])
        else
          @datetime = nil
        end
      rescue
        @datetime = nil
      end

      if @datetime.nil?
        render 'common/error', :status => :bad_request, :locals => { :message => "Sorry, you passed an invalid date" } and return unless @datetime.is_a? DateTime
      end

    end

  end


  # Convert a date and/or time passed un-RESTfully in the URL in to keys in params[]

  def convert_url_parameters


    # Convert the date parameter in to year, month and day parameters, falling back to today

    if (params[:year].nil? && params[:month].nil? && params[:day].nil?) && !params[:date].nil? && params[:date].match(/(\d{4})\-(\d{2})\-(\d{2})/)
      params[:year] = $1
      params[:month] = $2
      params[:day] = $3
    end


    # Convert the time parameter from HH:MM to HHMM

    if !params[:time].nil? && params[:time].match(/(\d{2})\:(\d{2})/)
      params[:time] = $1 + $2
    end

    @date_yyyymmdd = params[:year] + "-" + params[:month] + "-" + params[:day] if (params[:year] && params[:month] && params[:day])

    begin
      @date_human = Date.parse(@date_yyyymmdd)
    rescue
      @date_human = nil
    end

  end

end
