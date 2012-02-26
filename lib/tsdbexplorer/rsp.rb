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

=begin rdoc

Library functions for handing data supplied by Retail Settlement Plan (RSP) and ATOC

=end

require 'tsdbexplorer/rsp/classes.rb'

module TSDBExplorer

  module RSP

    def RSP.import_msnf(filename)

      msnf_data = File.open(filename)
      file_size = File.size(filename)


      # Validate the file header

      header = msnf_data.first

 
      # Read in the rest of the MSNF

      msnf_entries = Array.new

      while(!msnf_data.eof)
      
        record = TSDBExplorer::RSP::parse_record(msnf_data.gets)
        break if record.nil?

        if record.is_a? TSDBExplorer::RSP::StationDetailRecord
          msnf_entries << StationName.new(record.to_hash)
        end

      end


      # Do the import

      StationName.import(msnf_entries)


      # Update the Redis caches

      TSDBExplorer::Realtime::cache_location_database

    end


    # Examine the record type of a record, parse it appropriate and return

    def RSP.parse_record(record)

      result = Hash.new
      result[:record_identity] = record[0]

      # Process the record using the built-in Class parser

      if result[:record_identity] == "A"
        result = TSDBExplorer::RSP::StationDetailRecord.new(record)
      elsif result[:record_identity] == "B"
        # No support for Station Table Numbers (obsolete)
      elsif result[:record_identity] == "C"
        # No support for Station Comments (obsolete)
      elsif result[:record_identity] == "L"
        # No support for Station Alias records
      elsif result[:record_identity] == "G"
        # No support for Groups
      elsif result[:record_identity] == "R"
        # No support for Connection Details (obsolete)
      elsif result[:record_identity] == "V"
        # No support for Routeing Groups
      elsif result[:record_identity] == "Z"
        result = nil
      else
         raise "Unsupported record type '#{result[:record_identity]}'"
      end

      return result

    end

  end

end
