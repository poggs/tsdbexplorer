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


  # Search for a schedule by location

  def search_location

    @location = find_tiploc_for_text(params[:location])

    if @location.nil? || @location == Array.new
      redirect_to :back, :flash => { :warn => "Couldn't find that location"  }
    elsif @location.is_a? ActiveRecord::Relation
      render 'choose_location'
    else

      @time = Time.now
      @date = Date.today

      begin
        @time = Time.parse(params[:target_date] + " " + params[:target_time])
        @date = Date.parse(params[:target_date])
      rescue
      end

      @range = Hash.new
      @range[:from] = @time - 30.minutes
      @range[:to] = @time + 1.hour

      @schedule = Location.where(:tiploc_code => @location.tiploc_code).runs_on(@date.to_s(:iso))

      if advanced_mode?
        @schedule = @schedule.passes_between(@range[:from].strftime('%H%M'), @range[:to].strftime('%H%M'))
      else
        @schedule = @schedule.between(@range[:from].strftime('%H%M'), @range[:to].strftime('%H%M'))
      end

    end

  end


  # Present a list of locations and allow one to be chosen

  def choose_location
  end


  # Present a setup/welcome page if there are no BasicSchedules, otherwise redirect back to the main page

  def setup

    redirect_to :action => 'index' if BasicSchedule.count > 0

  end


  # Display a single schedule

  def schedule

    @schedule = BasicSchedule.find_by_uuid(params[:uuid])

    render 'common/_schedule'

  end


  # Display the disclaimer

  def disclaimer
  end


  # Search the TIPLOC records for a value

  def search

    if params[:term].length == 3
      conditions = [ 'crs_code = ?', params[:term] ]
    else
      conditions = [ 'tiploc_code LIKE ? OR tps_description LIKE ?', '%' + params[:term].upcase + '%', '%' + params[:term].upcase + '%' ]
    end

    matches = Tiploc.find(:all, :conditions => conditions, :limit => 25).collect { |m| { :id => m.tiploc_code, :label => m.tps_description + " (" + (m.crs_code.blank? ? m.tiploc_code : m.crs_code) + ")", :value => m.tiploc_code } }

    render :json => matches

  end

  private


  # Find a location by looking for an exact CRS code or TIPLOC match, falling back on a fuzzy match on the description

  def find_tiploc_for_text(text)

    if text.length == 3
      location = Tiploc.find_by_crs_code(text.upcase)
    else
      location = Tiploc.find_by_tiploc_code(text)
      if location.nil?
        location = Tiploc.where('tps_description LIKE :search_text', { :search_text => '%' + text.upcase + '%' }).limit(25)
      end
    end

    return location

  end

end
