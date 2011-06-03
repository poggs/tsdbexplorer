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

    if params[:target_time]
      @time = Time.parse(params[:target_time])
    else
      @time = Time.now
    end

    range_from = (@time - 2.hours).strftime('%Y-%m-%d %H:%M:00')
    range_to = (@time + 2.hours).strftime('%Y-%m-%d %H:%M:00')

    @location = Tiploc.find_by_tiploc_code(params[:location])

    unless @location.nil?
      @schedule = Location.where("tiploc_code = ? and ((departure BETWEEN ? AND ?) OR (pass BETWEEN ? AND ?) OR (arrival BETWEEN ? AND ?))", @location.tiploc_code, range_from, range_to, range_from, range_to, range_from, range_to)
    end

  end


  # Display a single schedule

  def schedule

    @schedule = BasicSchedule.find_by_uuid(params[:uuid])

    render 'common/_schedule.erb'

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

end
