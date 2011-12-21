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

  helper_method :advanced_mode?

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


  # Return a string in the form YYYY-MM-DD based on the parameters passed in the URL

  def date_from_params

    params[:year] + "-" + params[:month].rjust(2, '0') + "-" + params[:day].rjust(2, '0')

  end

end
