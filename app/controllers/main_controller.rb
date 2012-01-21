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

  caches_page :index, :disclaimer, :about

  # Handle the front page

  def index

    @time = Time.now
    redirect_to :action => 'setup' if BasicSchedule.count == 0

    days_forward = 10

    @dates = Array.new
    today = Date.today
    @dates.push({ :yyyymmdd => today.to_s(:yyyymmdd), :human => 'Today' })

    (0..days_forward).to_a.each do |add_day|
      fwd_date = today + add_day.days
      @dates.push( :yyyymmdd => fwd_date.to_s(:yyyymmdd), :human => 'on ' + fwd_date.to_s )
    end

  end


  # Present a setup/welcome page if there are no BasicSchedules, otherwise redirect back to the main page

  def setup

    redirect_to :action => 'index' if BasicSchedule.count > 0

    @data_files = Dir.glob(::Rails.root.join($CONFIG['TIMETABLE']['path']).to_s + "/*")

    if @data_files.blank?
      render 'main/setup_part1'
    else

      @import_files = Array.new
      @components = Array.new

      @data_files.each do |f|
        if f.match(/\.MSN/)
          @import_files.push({ :filename => f, :description => 'Master Station Names File (MSNF)', :provider => 'ATOC', :data_type => :rsp_msnf })
        elsif f.match(/\.MCA/)
          @import_files.push({ :filename => f, :description => 'CIF-formatted timetable data', :provider => 'ATOC', :data_type => :rsp_cif })
        elsif f.match(/\.CIF/)
          @import_files.push({ :filename => f, :description => 'CIF-formatted timetable data', :provider => 'Network Rail', :data_type => :nr_cif })
        end
      end

      render 'main/setup_part2'

    end

  end


  # Display the disclaimer

  def disclaimer
  end


  # Display the about page

  def about
  end

end
