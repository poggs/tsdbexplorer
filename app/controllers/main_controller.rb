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
#  $Id: main_controller.rb 108 2011-04-19 20:25:19Z pwh $
#

class MainController < ApplicationController

  # Handle the front page

  def index

    @time = Time.now
    redirect_to :action => 'setup' if BasicSchedule.count == 0

  end



  # Search for a schedule by train identity or schedule UID

  def search_identity

    @time = Time.now

    @schedule = BasicSchedule

    unless params[:target_date].blank?
      @schedule = @schedule.runs_on(params[:target_date])
    end

    # Try a regex match on the search parameters, and look up by UID or identity as appropriate

    if params[:schedule].match(/^\w\d{5}$/)
      @schedule = @schedule.find_all_by_train_uid(params[:schedule].upcase)
    elsif params[:schedule].match(/^\d\w\d{2}$/) 
      @schedule = @schedule.find_all_by_train_identity(params[:schedule].upcase)
    end

    # If exactly one schedule has been returned, render the schedule page, otherwise render the default list of schedules

    redirect_to :controller => 'schedule', :action => 'index', :uuid => @schedule.first.uuid if @schedule.count == 1

    @location = Tiploc.find_by_tiploc_code(params[:location])

  end


  # Present a setup/welcome page if there are no BasicSchedules, otherwise redirect back to the main page

  def setup

    redirect_to :action => 'index' if BasicSchedule.count > 0

  end


  # Display the disclaimer

  def disclaimer
  end


end
