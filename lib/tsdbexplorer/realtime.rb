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

module TSDBExplorer

  module Realtime

    # Put the site in to maintenance mode

    def Realtime.set_maintenance_mode(reason)
      $REDIS.set('OTT:SYSTEM:MAINT', reason)
    end


    # Take the site out of maintenance mode

    def Realtime.clear_maintenance_mode
      $REDIS.del('OTT:SYSTEM:MAINT')
    end


    # Cache the location database in memory

    def Realtime.cache_location_database

      Tiploc.all.each do |l|
        l.tps_description = '' if l.tps_description.blank?
        l.crs_code = '' if l.crs_code.blank?
        $REDIS.hset('TIPLOC:' + l.tiploc_code, 'description', l.tps_description)
        $REDIS.hset('TIPLOC:' + l.tiploc_code, 'stanox', l.stanox)
        $REDIS.hset('TIPLOC:' + l.tiploc_code, 'crs_code', l.crs_code)
        $REDIS.hset('LOCATION:' + l.tps_description, 'tiploc', l.tiploc_code)
        $REDIS.hset('LOCATION:' + l.tps_description, 'crs_code', l.crs_code)
        $REDIS.hset('LOCATION:CIF:' + l.tps_description, 'tiploc', l.tiploc_code)
        $REDIS.hset('LOCATION:CIF:' + l.tps_description, 'stanox', l.stanox)
        $REDIS.hset('LOCATION:CIF:' + l.tps_description, 'crs_code', l.crs_code)
      end

      StationName.all.each do |l|
        $REDIS.hset('TIPLOC:' + l.tiploc_code, 'description', l.station_name) if l.cate_type != 9
        $REDIS.hset('TIPLOC:' + l.tiploc_code, 'tiploc', l.tiploc_code)
        $REDIS.hset('TIPLOC:' + l.tiploc_code, 'crs_code', l.crs_code)
        $REDIS.hset('LOCATION:' + l.station_name, 'description', l.station_name)
        $REDIS.hset('LOCATION:' + l.station_name, 'tiploc', l.tiploc_code)
        $REDIS.hset('LOCATION:' + l.station_name, 'crs_code', l.crs_code)
        $REDIS.hset('LOCATION:MSNF:' + l.station_name, 'description', l.station_name)
        $REDIS.hset('LOCATION:MSNF:' + l.station_name, 'tiploc', l.tiploc_code)
        $REDIS.hset('LOCATION:MSNF:' + l.station_name, 'crs_code', l.crs_code)
        $REDIS.rpush('CRS:' + l.crs_code + ':TIPLOCS', l.tiploc_code)
        $REDIS.hset('CRS:' + l.crs_code, 'description', l.station_name) if l.cate_type != 9
      end

    end


    module Status

      def Status.timetable_feed

        last_extract = CifFile.last
        limit = 2.days

        if last_extract.nil?
          status = :error
          message = "No CIF files have been imported"
        else

          last_data_from = Time.now - last_extract.extract_timestamp

          if last_data_from > limit
            status = :error
            message = "Last extract imported was #{CifFile.last.file_mainframe_identity} on #{last_extract.extract_timestamp.to_s(:human)}"
          else
            status = :ok
            message = "Last extract imported was #{CifFile.last.file_mainframe_identity} on #{last_extract.extract_timestamp.to_s(:human)}"
          end

        end

        return Struct.new(:status, :message).new(status, message)

      end

      def Status.train_describer_feed

        last_update = $REDIS.get('STATS:TD:UPDATE').to_i
        limit = 30.seconds

        if last_update.nil?
          status = :unknown
          message = "No TD updates processed"
        elsif last_update < (Time.now.to_i - limit)
          status = :error
          message = "No TD updates received for the past #{limit} seconds"
        else
          status = :ok
          message = "Last TD update processed #{Time.now.to_i - last_update} seconds ago"
        end

        return Struct.new(:status, :message).new(status, message)

      end

      def Status.trust_feed

        last_update = $REDIS.get('STATS:TRUST:UPDATE').to_i
        limit = 2.minutes

        if last_update.nil?
          status = :unknown
          message = "No TRUST updates processed"
        elsif last_update < (Time.now.to_i - limit)
          status = :error
          message = "No TRUST updates received for the past #{limit} seconds"
        else
          status = :ok
          message = "Last TRUST update processed #{Time.now.to_i - last_update} seconds ago"
        end

        return Struct.new(:status, :message).new(status, message)

      end

    end

  end

end

