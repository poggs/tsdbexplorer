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

  module Geography

    # Import non-redistributable static data

    def Geography.import_static_data(path='data/static')

      # Import ELR data

      elr_records = Array.new

      FasterCSV.foreach(path + '/elr_list.csv') do |elr_line|
        elr_records << GeoElr.new(:elr_code => elr_line[0], :line_name => elr_line[1])
      end

      elr_result = GeoElr.import(elr_records)


      # Import location data

      point_records = Array.new

      FasterCSV.foreach(path + '/locations.csv') do |point_line|
        point_records << GeoPoint.new(:location_name => point_line[0], :route_code => point_line[1], :elr_code => point_line[2], :miles => point_line[3], :chains => point_line[4])
      end

      point_result = GeoPoint.import(point_records)

      return Struct.new(:status, :message).new(:status => :ok, :message => "#{elr_records.count} ELR records and #{point_records.count} point records processed")

    end

  end

end
