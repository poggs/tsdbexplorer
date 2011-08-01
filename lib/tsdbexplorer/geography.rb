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

    # Import static ELR data, which is not redistributable.

    def Geography.import_static_elr_data(filename)

      elr_data = File.open(filename)
      elr_records = Array.new

      elr_data.each do |elr_line|
        record = elr_line.chop.split(/,/)
        elr_records << GeoElr.new(:elr_code => record[0], :line_name => record[1])
      end

      result = GeoElr.import(elr_records)

      return Struct.new(:status, :message).new(:status => :ok, :message => result.num_inserts.to_s + ' records processed')

    end

  end

end
