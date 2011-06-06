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

  module TDnet

    # Parse a TD.net Raw TD Message and return the content as a Hash

    def TDnet.parse_message(message)

      result = Hash.new
      result[:message_type] = message[10..11]

      structure = case result[:message_type]
        when "CA"
          { :format => [ [ :td_identity, 2 ], [ :message_type, 2 ], [ :from_berth, 4 ], [ :to_berth, 4 ], [ :train_description, 4 ], [ :timestamp, 6 ] ] }
        when "CB"
          { :format => [ [ :td_identity, 2 ], [ :message_type, 2 ], [ :from_berth, 4 ], [ :train_description, 4 ], [ :timestamp, 6 ] ] }
        when "CC"
          { :format => [ [ :td_identity, 2 ], [ :message_type, 2 ], [ :to_berth, 4 ], [ :train_description, 4 ], [ :timestamp, 6 ] ] }
        when "CT"
          { :format => [ [ :td_identity, 2 ], [ :message_type, 2 ], [ :timestamp_four, 4 ], [ :timestamp, 6 ] ] }
        when "SF"
          { :format => [ [ :td_identity, 2 ], [ :message_type, 2 ], [ :address, 2 ], [ :data, 2 ], [ :timestamp, 6 ] ] }
        when "SG"
          { :format => [ [ :td_identity, 2 ], [ :message_type, 2 ], [ :address, 2 ], [ :data, 8 ], [ :timestamp, 6 ] ] }
        when "SH"
          { :format => [ [ :td_identity, 2 ], [ :message_type, 2 ], [ :address, 2 ], [ :data, 8 ], [ :timestamp, 6 ] ] }
        else
          raise "Unsupported record type '#{result[:message_type]}'"
      end


      # Slice up the record in to its fields as defined above, starting at
      # column 8, as we already have the record identity parsed

      pos = 8

      structure[:format].each do |field|
        field_name = field[0].to_sym
        value = message.slice(pos, field[1])
        result[field_name] = value.blank? ? nil : value
        pos = pos + field[1]
      end

      return result

    end


    # Parse a TD.net compact message and return the content as a Hash

    def TDnet.parse_compact_message(xml)

      result = Hash.new

      structure = { 'TDMessageType' => :message_type, 'timestamp' => :timestamp, 'TDReportTime' => :timestamp_four, 'TDIdentity' => :td_identity, 'trainIdentity' => :train_description, 'fromBerthAddress' => :from_berth, 'toBerthAddress' => :to_berth, 'equipmentStatusAddress' => :address, 'equipmentBaseScanAddress' => :address, 'equipmentStatus' => :data, 'equipmentBaseScan' => :data }

      parsed_xml = Nokogiri::parse(xml)

      parsed_xml.xpath('/TDCompact').first.attributes.collect do |k,v|
        result[structure[k]] = v.value
      end

      return result

    end

  end

end
  