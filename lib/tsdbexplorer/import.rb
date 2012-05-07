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

  module Import

    # Import the location data set

    def Import.locations(filename='data/static/locations.csv')

      raise "Location data not found at #{filename}" unless File.readable?(filename)

      # Wrap everything in a Redis transaction

      $REDIS.multi do

        old_tiplocs = $REDIS.keys("TIPLOC:*")

        unless old_tiplocs.nil?
          old_tiplocs.each do |t|
            $REDIS.del(t)
          end
        end


        old_stanox = $REDIS.keys("STANOX:*")

        unless old_stanox.nil?
          old_stanox.each do |s|
            $REDIS.del(s)
          end
        end

        location_records = Array.new

        CSV.foreach(filename, { :col_sep => ";" }) do |location|
          location_records << Point.new(:full_name => location[0], :short_name => location[1], :stanox => location[2], :stanme => location[3], :tiploc => location[5], :latitude => location[6], :longitude => location[7])
          $REDIS.hset("TIPLOC:#{location[5]}", "full_name", location[0])
          $REDIS.hset("TIPLOC:#{location[5]}", "short_name", location[0])
          $REDIS.hset("TIPLOC:#{location[5]}", "stanme", location[3])
          $REDIS.hset("STANOX:#{location[2]}", "tiploc", location[5])
        end

        location_result = Point.import(location_records)

      end

    end
      
  end

end
