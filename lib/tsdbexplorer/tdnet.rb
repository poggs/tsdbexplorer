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


    # Parse a TD.net raw message and return the content as a hash

   def TDnet.parse_raw_message(message)

     result = Hash.new
     result[:message_type] = message[0..3]

     structure = case result[:message_type]
       when "0001"
         { :convert_yyyymmddhhmmss => [ :train_creation_timestamp, :schedule_origin_depart_timestamp, :schedule_start_date, :schedule_end_date, :tp_origin_timestamp ], :format => [ [ :train_id, 10 ], [ :train_creation_timestamp, 14 ], [ :schedule_origin_stanox, 5 ], [ :schedule_origin_depart_timestamp, 14 ], [ :train_uid, 6 ], [ :schedule_start_date, 14 ], [ :schedule_end_date, 14 ], [ :schedule_source, 1 ], [ :schedule_type, 1 ], [ :schedule_wtt_id, 5 ], [ :d1266_record_number, 5 ], [ :tp_origin_location, 5 ], [ :tp_origin_timestamp, 14 ], [ :train_call_type, 1 ], [ :train_call_mode, 1 ], [ :toc_id, 2 ], [ :train_service_code, 8 ], [ :train_file_address, 3 ] ] }
       when "0002"
         { :convert_yyyymmddhhmmss => [ :train_cancellation_timestamp, :departure_timestamp, :original_location_timestamp ], :format => [ [ :train_id, 10 ], [ :train_cancellation_timestamp, 14 ], [ :location, 5 ], [ :departure_timestamp, 14 ], [ :original_location, 5 ], [ :original_location_timestamp, 14 ], [ :cancellation_type, 1 ], [ :current_train_id, 10 ], [ :train_service_code, 8 ], [ :cancellation_reason_code, 2 ], [ :division_code, 2 ], [ :toc, 2 ], [ :variation_status, 1 ], [ :train_file_address, 3 ] ] }
       when "0003"
         { :convert_yyyymmddhhmmss => [ :actual_timestamp, :gbtt_event_timestamp, :planned_event_timestamp, :original_location_timestamp,  ], :format => [ [ :train_id, 10 ], [ :actual_timestamp, 14 ], [ :location_stanox, 5 ], [ :gbtt_event_timestamp, 14 ], [ :planned_event_timestamp, 14 ], [ :original_location, 5 ], [ :original_location_timestamp, 14 ], [ :planned_event_type, 1 ], [ :event_type, 1 ], [ :planned_event_source, 1 ], [ :correction_indicator, 1 ], [ :offroute_indicator, 1 ], [ :direction_indicator, 1 ], [ :line_indicator, 1 ], [ :platform, 2 ], [ :route, 1 ], [ :current_train_id, 10 ], [ :train_service_code, 8 ], [ :division_code, 2 ], [ :toc_id, 2 ], [ :timetable_variation, 3 ], [ :variation_status, 1 ], [ :next_report, 5 ], [ :next_report_run_time, 3 ], [ :train_terminated, 1 ], [ :delay_monitoring_point, 1 ], [ :train_file_address, 3 ], [ :reporting_stanox, 5 ], [ :auto_expected, 1 ] ] }
       when "0004"
         { :convert_yyyymmddhhmmss => [ :actual_timestamp ], :format => [ [ :wtt_id, 4 ], [ :actual_timestamp, 14 ], [ :location_stanox, 5 ], [ :event_type, 1 ], [ :direction_indicator, 1 ], [ :line_indicator, 1 ], [ :platform, 2 ], [ :route, 1 ], [ :division_code, 2 ], [ :variation_status, 1 ] ] }
       when "0005"
         { :convert_yyyymmddhhmmss => [ :reinstatement_timestamp, :departure_timestamp, :original_location_timestamp ], :format => [ [ :train_id, 10 ], [ :reinstatement_timestamp, 14 ], [ :location_stanox, 5 ], [ :departure_timestamp, 14 ], [ :original_location, 5 ], [ :original_location_timestamp, 14 ], [ :current_train_id, 10 ], [ :train_service_code, 8 ], [ :division_code, 2 ], [ :toc_id, 2 ], [ :variation_status, 1 ], [ :train_file_address, 3 ] ] }
       when "0006"
         { :convert_yyyymmddhhmmss => [ :change_of_origin_timestamp, :departure_timestamp, :original_location_timestamp ], :format => [ [ :train_id, 10 ], [ :change_of_origin_timestamp, 14 ], [ :location_stanox, 5 ], [ :departure_timestamp, 14 ], [ :original_location, 5 ], [ :original_location_timestamp, 14 ], [ :current_train_id, 10 ], [ :train_service_code, 8 ], [ :reason_code, 2 ], [ :division_code, 2 ], [ :toc_id, 2 ], [ :variation_status, 1 ], [ :train_file_address, 3 ] ] }
       when "0007"
         { :convert_yyyymmddhhmmss => [ :event_timestamp ], :format => [ [ :train_id, 10 ], [ :event_timestamp, 14 ], [ :revised_train_id, 10 ], [ :current_train_id, 10 ], [ :train_service_code, 8 ], [ :train_file_address, 3 ] ] }
       when "0008"
         { :convert_yyyymmddhhmmss => [ :event_timestamp, :planned_timestamp, :original_timestamp ], :format => [ [ :train_id, 10 ], [ :event_timestamp, 14 ], [ :revised_location, 5 ], [ :planned_timestamp, 14 ], [ :original_location, 5 ], [ :original_timestamp, 14 ], [ :current_train_id, 10 ], [ :train_service_code, 8 ], [ :train_file_address, 3 ] ] }
     end

      structure[:format] = [ [ :message_type, 4 ], [ :message_queue_timestamp, 14 ], [ :source_system_id, 20 ], [ :original_data_source, 20 ], [ :user_id, 8 ], [ :source_dev_id, 8 ] ] + structure[:format]
      structure[:strip] = [ :source_system_id, :original_data_source, :user_id, :source_dev_id ]
      structure[:convert_yyyymmddhhmmss] = [ :message_queue_timestamp ] + ( structure[:convert_yyyymmddhhmmss] || [] )

      # Slice up the record in to its fields as defined above

      pos = 0

      structure[:format].each do |field|
        field_name = field[0].to_sym
        value = message.slice(pos, field[1])
        result[field_name] = value.blank? ? nil : value
        pos = pos + field[1]
      end


      # Delete any unnecessary fields

      if structure.has_key? :delete
        structure[:delete].each do |field|
          result.delete field
        end
      end


      # Reformat certain fields if required

      if structure.has_key? :convert_yyyymmddhhmmss
        structure[:convert_yyyymmddhhmmss].each do |field|
          result[field] = TSDBExplorer::yyyymmddhhmmss_to_time(result[field])
        end
      end

      if structure.has_key? :strip
        structure[:strip].each do |field|
          result[field].strip! unless result[field].nil?
        end
      end

      return result

    end


    # Process a TRUST train activation message.  This will search the
    # scheduled services for the UID given and the date passed (normally be
    # today), and if the schedule is found, a clone of it and the calling
    # points will be created in the Daily tables.

    def TDnet.process_trust_activation(uid, run_date, unique_train_id)

      schedule = BasicSchedule.find_by_train_uid(uid, run_date)

      if schedule.nil?
        puts "  Schedule not found for activation of train #{msg[:train_uid]}"
        next
      end

      ds_record = Hash.new

      DailySchedule.new.attributes.keys.each do |attr|
        ds_record[attr] = schedule[attr]
      end

      ds_record[:runs_on] = run_date
      ds_record[:train_identity_unique] = unique_train_id
      ds_record[:uuid] = UUID.generate

      DailySchedule.create!(ds_record)
puts DailySchedule.first.inspect
      location_list = Array.new

      schedule.locations.each do |location|

        dsl_record = Hash.new

        DailyScheduleLocation.new.attributes.keys.each do |attr|
          dsl_record[attr] = location[attr]
        end

        dsl_record[:daily_schedule_uuid] = ds_record[:uuid]

        [ :arrival, :public_arrival, :pass, :departure, :public_departure ].each do |time_attr|
          dsl_record[time_attr] = Time.parse(run_date.to_s + " " + TSDBExplorer::normalise_time(location[time_attr])) unless location[time_attr].nil?
        end

        location_list << DailyScheduleLocation.new(dsl_record)

      end

      DailyScheduleLocation.import(location_list)

    end

  end

end
