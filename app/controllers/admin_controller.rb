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

class AdminController < ApplicationController

  # Redirect to the overview page

  def index
    redirect_to :action => 'overview'
  end 


  # Overview page

  def overview

    @pills = [ 'Overview', 'Timetable', 'Real-Time', 'Memory' ]

    @status = Hash.new
    @status[:timetable_feed] = TSDBExplorer::Realtime::Status.timetable_feed()
    @status[:train_describer_feed] = TSDBExplorer::Realtime::Status.train_describer_feed
    @status[:trust_feed] = TSDBExplorer::Realtime::Status.trust_feed



    @stats[:cifs_imported] = CifFile.count
    @stats[:last_cif_import] = CifFile.maximum(:created_at)


  end


  # Timetable Administration

  def timetable

    @pills = [ 'Overview', 'Timetable', 'Real-Time', 'Memory' ]

    @stats = Hash.new
    @stats[:tiplocs] = Tiploc.count
    @stats[:basic_schedules] = BasicSchedule.count
    @stats[:earliest_schedule] = BasicSchedule.minimum(:runs_from)
    @stats[:latest_schedule] = BasicSchedule.maximum(:runs_to)
    @stats[:daily_schedules] = DailySchedule.count

    @all_timetables = Hash.new

    tt_dir = Dir.open($CONFIG['TIMETABLE']['path'])

    tt_dir.each do |t|

      next if File.directory? t

      if tt_file = File.open($CONFIG['TIMETABLE']['path'] + "/" + t)
        header = TSDBExplorer::CIF::parse_record(tt_file.readline)
        info = Hash.new
        info[:filename] = t
        info[:file_mainframe_identity] = header.file_mainframe_identity
        info[:extract_type] = header.update_indicator
        info[:imported] = true if CifFile.where(:file_mainframe_identity => header.file_mainframe_identity).count > 0
        @all_timetables[t] = info
      end

    end

  end


  # Real-Time

  def realtime

    @pills = [ 'Overview', 'Timetable', 'Real-Time', 'Memory' ]

    @stats = Hash.new
    @stats[:trust_messages] = $REDIS.get('STATS:TRUST:PROCESSED')
    @stats[:td_messages] = $REDIS.get('STATS:TD:PROCESSED')
    @stats[:vstp_messages] = $REDIS.get('STATS:VSTP:PROCESSED')
    @stats[:tsr_messages] = $REDIS.get('STATS:TSR:PROCESSED')

  end


  # In-Memory Database

  def memory

    @pills = [ 'Overview', 'Timetable', 'Real-Time', 'Memory' ]

    @redis = $REDIS.info

  end

end
