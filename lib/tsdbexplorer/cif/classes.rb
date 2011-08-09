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

  module CIF

    class Header

      attr_reader :file_mainframe_identity, :date_of_extract, :time_of_extract, :current_file_ref, :last_file_ref, :update_indicator, :version, :user_extract_start_date, :user_extract_end_date, :mainframe_username, :extract_date
      attr_accessor :file_mainframe_identity, :date_of_extract, :time_of_extract, :current_file_ref, :last_file_ref, :update_indicator, :version, :user_extract_start_date, :user_extract_end_date, :mainframe_username, :extract_date

      def initialize(record)

        self.file_mainframe_identity = record[2..21]
        self.date_of_extract = record[22..27]
        self.time_of_extract = record[28..31]
        self.current_file_ref = record[32..38]
        self.last_file_ref = record[39..45]
        self.update_indicator = record[46..46]
        self.version = record[47..47]
        self.user_extract_start_date = record[48..53]
        self.user_extract_end_date = record[54..59]

        raise "Mainframe identity is not valid" unless self.file_mainframe_identity.match(/TPS.U(.{6}).PD(.{6})/)
        self.mainframe_username = $1
        self.extract_date = $2

      end

    end

  end

end
