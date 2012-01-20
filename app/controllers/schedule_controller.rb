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

  # A dummy action to catch a request for the URL with no parameters

  def index

    redirect_to root_url

  end


  # Search for a schedule

  def search

    redirect_to :root and return if params[:by].nil? || params[:term].blank?

    params[:term].upcase!

    @schedule = BasicSchedule

    @schedule = @schedule.runs_on(@date)

    if params[:by] == "train_id"

      @schedule = @schedule.where(:train_identity => params[:term])

      if @schedule.count == 0

        msg = "We couldn't find any trains with the train identity #{params[:term]}"
        msg = msg + " running on #{@date.to_s}" if @date

        render 'common/error', :status => :not_found, :locals => { :message => msg }

      elsif @schedule.count == 1

        if @date
          redirect_to :action => 'schedule_by_uid_and_run_date', :uid => @schedule.first.train_uid, :year => @date.year.to_s, :month => @date.month.to_s.rjust(2, '0'), :day => @date.day.to_s.rjust(2, '0')
        else
          redirect_to :action => 'schedule_by_uid', :uid => @schedule.first.train_uid
        end

      end

    elsif params[:by] == "schedule_uid"

      @schedule = @schedule.where(:train_uid => params[:term])

      if @schedule.count == 0

        msg = "We couldn't find any schedules with the UID #{params[:term]}"
        msg = msg + " valid on #{Date.parse(params[:date]).to_s}" if params[:date] 

        render 'common/error', :status => :not_found, :locals => { :message => msg } if @schedule.count == 0

      elsif @schedule.count == 1

        if @date
          redirect_to :action => 'schedule_by_uid_and_run_date', :uid => @schedule.first.train_uid, :year => @date.year.to_s, :month => @date.month.to_s.rjust(2, '0'), :day => @date.day.to_s.rjust(2, '0')
        else
          redirect_to :action => 'schedule_by_uid', :uid => @schedule.first.train_uid
        end

      end

    else

      render 'common/error', :status => :bad_request, :locals => { :message => "We don't know how to search by #{params[:by]}" }

    end

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

    @schedule = BasicSchedule.runs_on_by_uid_and_date(params[:uid], @date).first

    render 'common/error', :status => :not_found, :locals => { :message => "We couldn't find the schedule #{params[:uid]} running on #{@date_yyyymmdd}.  The schedule may not be valid for this date." } if @schedule.nil?

    @as_run = DailySchedule.runs_on_by_uid_and_date(params[:uid], @date_yyyymmdd).first

  end


  # Display real-time information

  def actual

    @schedule = DailySchedule.find_by_uuid(params[:uuid])

    render 'common/_schedule_instance'

  end

end

