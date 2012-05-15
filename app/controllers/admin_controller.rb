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

  # This controller is only accessible to logged-in users who have admin rights

  before_filter :require_admin!


  # Redirect to the overview page

  def index
    redirect_to :action => 'overview'
  end 


  # Overview page

  def overview

    @pills = pills

    @status = Hash.new
    @status[:timetable_feed] = TSDBExplorer::Realtime::Status.timetable_feed
    @status[:train_describer_feed] = TSDBExplorer::Realtime::Status.train_describer_feed
    @status[:trust_feed] = TSDBExplorer::Realtime::Status.trust_feed

  end


  # Timetable Administration

  def timetable

    @pills = pills

    @stats = Hash.new
    @stats[:cifs_imported] = CifFile.count
    @stats[:tiplocs] = Tiploc.count
    @stats[:basic_schedules] = BasicSchedule.count || "0"
    @stats[:earliest_schedule] = BasicSchedule.minimum(:runs_from)
    @stats[:latest_schedule] = BasicSchedule.maximum(:runs_to)

    if CifFile.count > 0
      last_cif_import = CifFile.last
      @stats[:last_cif_import] = "The last CIF file imported was #{last_cif_import.file_ref} generated on #{last_cif_import.extract_timestamp.to_s(:human)}"
    else
      @stats[:last_cif_import] = "No CIF files have been imported"
    end

  end


  # Import

  def import

    @pills = pills

    @all_timetables = Hash.new

    if ($CONFIG.has_key? 'DATA') && ($CONFIG['DATA'].has_key? 'path') && Dir.exist?(::Rails.root.join($CONFIG['DATA']['path']))

      tt_dir = Dir.open(::Rails.root.join($CONFIG['DATA']['path']))

      tt_dir.each do |t|

        next if File.directory? t

        if tt_file = File.open(tt_dir.path + "/" + t)
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

  end


  # Real-Time

  def realtime

    @pills = pills

    @stats = Hash.new

    @stats[:trust_messages] = $REDIS.get('STATS:TRUST:PROCESSED') || "0"
    @stats[:trust_activations] = $REDIS.hget('STATS:TRUST', '0001')
    @stats[:trust_cancellations] = $REDIS.hget('STATS:TRUST', '0002')
    @stats[:trust_movements] = $REDIS.hget('STATS:TRUST', '0003')
    @stats[:trust_unidentified_trains] = $REDIS.hget('STATS:TRUST', '0004')
    @stats[:trust_train_reinstatements] = $REDIS.hget('STATS:TRUST', '0005')
    @stats[:trust_change_of_origins] = $REDIS.hget('STATS:TRUST', '0006')
    @stats[:trust_change_of_identities] = $REDIS.hget('STATS:TRUST', '0007')
    @stats[:trust_change_of_locations] = $REDIS.hget('STATS:TRUST', '0008')

    [ :trust_messages, :trust_activations, :trust_cancellations, :trust_movements, :trust_unidentified_trains, :trust_train_reinstatements, :trust_change_of_origins, :trust_change_of_identities, :trust_change_of_locations ].each do |m|
      @stats[m.to_sym] = "0" if @stats[m.to_sym].nil?
    end

    @stats[:td_messages] = $REDIS.get('STATS:TD:PROCESSED') || "0"
    @stats[:td_areas] = $REDIS.keys('TD:*:BERTHS').count
    @stats[:td_message_ca] = $REDIS.hget('STATS:TD', 'CA')
    @stats[:td_message_cb] = $REDIS.hget('STATS:TD', 'CB')
    @stats[:td_message_cc] = $REDIS.hget('STATS:TD', 'CC')
    @stats[:td_message_ct] = $REDIS.hget('STATS:TD', 'CT')

    [ :td_message_ca, :td_message_cb, :td_message_cc, :td_message_ct ].each do |m|
      @stats[m.to_sym] = "0" if @stats[m.to_sym].nil?
    end

    @stats[:vstp_messages] = $REDIS.get('STATS:VSTP:PROCESSED') || "0"

    @stats[:tsr_messages] = $REDIS.get('STATS:TSR:PROCESSED') || "0"

  end


  # In-Memory Database

  def memory

    @pills = pills

    @redis = $REDIS.info

  end


  # User management

  def manageusers

    @pills = pills

    @users = User.all

  end


  # Search static data

  def search

    @pills = pills

    if params[:search]

      # Try to convert the search string to an integer - if it's zero, it isn't an integer

      if params[:search].to_i == 0

        search_string = "%#{params[:search]}%"
        @matches = Point.where("full_name LIKE ? OR short_name LIKE ? OR stanme LIKE ? OR tiploc LIKE ?", search_string, search_string, search_string, search_string)

      else

        @matches = Point.where(:stanox => params[:search])

      end

      @matches = @matches.limit(50)

    end

  end


  private

  def pills
    [ [ 'System' , [ 'Overview', 'Timetable', 'Import', 'Real-Time', 'Memory' ] ], [ 'Data', [ 'Search' ] ], [ 'Authentication', [ 'Manage users' ] ] ]
  end

end
