#
#  This file is part of TSDBExplorer.
#
#  TSDBExplorer is free software@ you can redistribute it and/or modify it
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
#  with TSDBExplorer.  If not, see <http@//www.gnu.org/licenses/>.
#
#  $Id$
#

module TSDBExplorer

  module RSP

    class StationDetailRecord

      attr_reader :station_name, :cate_type, :tiploc_code, :subsid_crs_code, :crs_code, :easting, :northing, :estimated_coords, :loc_latitude, :loc_longitude, :estimated_coords, :change_time
      attr_accessor :station_name, :cate_type, :tiploc_code, :subsid_crs_code, :crs_code, :easting, :northing, :estimated_coords, :loc_latitude, :loc_longitude, :estimated_coords, :change_time

      def initialize(record)

        self.station_name = record[5..34].strip
        self.cate_type = record[35]
        self.tiploc_code = record[36..42].strip
        self.subsid_crs_code = record[43..45]
        self.crs_code = record[49..51]
        self.easting = record[52..56].to_i
        self.estimated_coords = record[57]
        self.northing = record[58..62].to_i
        self.change_time = record[63..64]

      end

      def to_hash

        data = Hash.new
        fields = :station_name, :cate_type, :tiploc_code, :subsid_crs_code, :crs_code, :estimated_coords, :change_time

        fields.each do |f|
          data[f] = self.send(f)
        end

        return data

      end

    end

  end

end
