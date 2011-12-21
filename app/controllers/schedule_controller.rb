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

class ScheduleController < ApplicationController

  # Display a single schedule

  def index

    @schedule = nil
    @schedule = BasicSchedule.find_by_uuid(params[:uuid]) if params[:uuid]

    @as_run = DailySchedule.find_all_by_train_uid(@schedule.train_uid)

  end


  # Search for a schedule by UID or train ID

  def search

    @schedule = BasicSchedule

    # Optionally limit to a date

    unless params[:date].nil?
      @schedule = @schedule.runs_on(params[:date])
    end


    # Try a regex match on the search parameters, and look up by UID or identity as appropriate

    if params[:schedule].match(/^\w\d{5}$/)
      @schedule = @schedule.find_all_by_train_uid(params[:schedule].upcase)
    elsif params[:schedule].match(/^\d\w\d{2}$/) 
      @schedule = @schedule.find_all_by_train_identity(params[:schedule].upcase)
    end

    # If exactly one schedule has been returned, render the schedule page, otherwise render the default list of schedules

    redirect_to :controller => 'schedule', :action => 'schedule_by_uid', :uid => @schedule.first.train_uid if @schedule.count == 1

  end


  # Display a schedule by UID

  def schedule_by_uid

    @schedule = BasicSchedule.where(:train_uid => params[:uid])

    render 'common/error', :status => :not_found, :locals => { :message => "We couldn't find the schedule #{params[:uid]}." } and return if @schedule.blank?

    @date = Date.today
    @date_array = @schedule.first.date_array

  end


  # Display a schedule by UID and date

  def schedule_by_uid_and_run_date

    @schedule = BasicSchedule.runs_on_by_uid_and_date(params[:uid], date_from_params).first

    render 'common/error', :status => :not_found, :locals => { :message => "We couldn't find the schedule #{params[:uid]} running on #{date_from_params}.  The schedule may not be valid for this date." } if @schedule.nil?

    @as_run = DailySchedule.runs_on_by_uid_and_date(params[:uid], date_from_params).first

  end


  # Display real-time information

  def actual

    @schedule = DailySchedule.find_by_uuid(params[:uuid])

    render 'common/_schedule_instance'

  end

end

