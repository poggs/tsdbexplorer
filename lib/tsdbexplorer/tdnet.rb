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

    # Parse a SMARTS raw TD Message and return the content as a Hash

    def TDnet.parse_smart_message(message)

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


    # Process a TRUST message

   def TDnet.process_trust_message(raw_message)

      message = parse_raw_message(raw_message)

      case message[:message_type]
        when "0001"   # Train activation
          result = process_trust_activation(message[:train_uid], message[:schedule_origin_depart_timestamp].strftime('%Y-%m-%d'), message[:train_id])
        when "0002"   # Train cancellation
          result = process_trust_cancellation(message[:train_id], message[:train_cancellation_timestamp], message[:cancellation_reason_code])
        when "0003"   # Train movement
          result = process_trust_movement(message[:train_id], message[:event_type], message[:actual_timestamp], message[:location_stanox], message[:offroute_indicator], message[:platform], message[:line_indicator], message[:planned_event_source])
        when "0004"   # Unidentified train report
          result = Struct.new(:status, :message).new(:warn, "Unidentified Train report not processed - pending support")
        when "0005"   # Train reinstatement report
          result = process_trust_reinstatement(message[:train_id], message[:reinstatement_timestamp])
        when "0006"   # Change of Origin report
          result = process_trust_change_of_origin(message[:train_id], message[:change_of_origin_timestamp], message[:reason_code], message[:location_stanox])
        when "0007"   # Change of Identity report
          result = Struct.new(:status, :message).new(:warn, "Change of Identity report not processed - pending support")
        when "0008"   # Change of Location report
          result = Struct.new(:status, :message).new(:warn, "Change of Location report not processed - pending support")
        else
          result = Struct.new(:status, :message).new(:warn, "Received unsupported message type #{message[:message_type]}")
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

      uid.strip!

      schedule = BasicSchedule.runs_on_by_uid_and_date(uid, run_date).first

      if schedule.nil?
        return Struct.new(:status, :message).new(:error, 'No schedule found for activation of train ' + uid)
      end

      ds_record = Hash.new

      DailySchedule.new.attributes.keys.each do |attr|
        ds_record[attr] = schedule[attr] if schedule.respond_to? attr.to_sym
      end

      ds_record[:runs_on] = run_date
      ds_record[:train_identity_unique] = unique_train_id
      ds_record[:uuid] = UUID.generate

      DailySchedule.create!(ds_record)

      location_list = Array.new

      schedule.locations.each do |location|

        dsl_record = Hash.new

        DailyScheduleLocation.new.attributes.keys.each do |attr|
          dsl_record[attr] = location[attr]
        end

        dsl_record[:daily_schedule_uuid] = ds_record[:uuid]

        [ :arrival, :public_arrival, :pass, :departure, :public_departure ].each do |time_attr|
          dsl_record[time_attr] = Time.parse(run_date.to_s + " " + TSDBExplorer::normalise_time(location[time_attr])) unless location[time_attr].nil? || location[time_attr].blank?
        end

        location_list << DailyScheduleLocation.new(dsl_record)

      end

      DailyScheduleLocation.import(location_list)

      return Struct.new(:status, :message).new(:ok, 'Activated train UID ' + uid + ' on ' + run_date + ' as train identity ' + unique_train_id)

    end


    # Process a TRUST cancellation.  Currently, only full-schedule cancellations are supported.

    def TDnet.process_trust_cancellation(train_identity, timestamp, reason)

      ds = DailySchedule.find_by_train_identity_unique(train_identity)

      if ds.nil?
        return Struct.new(:status, :message).new(:error, 'Failed to cancel train ' + train_identity + ' schedule not found')
      end

      ds.cancelled = true
      ds.cancellation_reason = reason
      ds.cancellation_timestamp = timestamp
      ds.save!

      return Struct.new(:status, :message).new(:ok, 'Cancelled train ' + train_identity + ' due to reason ' + reason)

    end


    # Process a TRUST reinstatement message.  This indicates that a train which was previously cancelled has been reinstated - it may be subject to further alteration

    def TDnet.process_trust_reinstatement(train_identity, reinstatement_timestamp)

      schedule = DailySchedule.find_by_train_identity_unique(train_identity)
      return Struct.new(:status, :message).new(:error, 'Message for unactivated train ' + train_identity + ' - ignoring') if schedule.nil?
      return Struct.new(:status, :message).new(:error, 'Reinstatement for uncancelled train ' + train_identity + ' - ignoring') unless schedule.cancelled?

      schedule.cancelled = false
      schedule.cancellation_reason = nil
      schedule.save

      return Struct.new(:status, :message).new(:ok, 'Reinstated train ' + train_identity)

    end


    # Process a TRUST movement message

    def TDnet.process_trust_movement(train_identity, event_type, timestamp, location_stanox, offroute_indicator, platform, line, planned_event_source)

      schedule = DailySchedule.find_by_train_identity_unique(train_identity)
      return Struct.new(:status, :message).new(:error, 'Message for unactivated train ' + train_identity + " - ignoring") if schedule.nil?

      # TODO: Handle off-route movement messages

      # More than one TIPLOC may exist for a particular STANOX, so we must
      # retrieve all TIPLOCs for this STANOX and iterate through the list to
      # find the one that matches a point in this train's schedule

      location = Tiploc.find_all_by_stanox(location_stanox)
      return Struct.new(:status, :message).new(:error, 'Failed to find STANOX location ' + location_stanox + ' for train ' + train_identity) if location.nil? || location == []

      point = nil

      location.each do |possible_location|
        next unless point.nil?
        point = schedule.locations.find_by_tiploc_code(possible_location.tiploc_code)
      end

      return Struct.new(:status, :message).new(:error, 'Failed to find the following schedule location(s) ' + location.collect { |x| x.tiploc_code }.join(", ") + ' for train ' + train_identity) if point.nil?

      # Update the actual arrival, departure or passing time

      if point.pass.nil?
        if event_type == 'A'
          point.actual_arrival = timestamp
          point.arrival_source = "TRUST"
        elsif event_type == 'D'
          point.actual_departure = timestamp
          point.departure_source = "TRUST"
        else
          return Struct.new(:status, :message).new(:error, 'Unknown event type ' + event_type + ' for movement at ' + location)
        end
      else
        point.actual_pass = timestamp
        point.pass_source = "TRUST"
      end

      point.event_source = planned_event_source
      point.actual_platform = platform.strip unless platform.nil?
      point.actual_line = line.strip unless line.nil?

      point.save!

      return Struct.new(:status, :message).new(:ok, 'Processed movement type ' + event_type + ' for train ' + train_identity + ' at ' + point.tiploc.tps_description + ' on ' + timestamp.strftime("%Y-%m-%d %H:%M"))

    end


    # Process a TRUST change of origin message.  COO messages indicate the calling points between the 

    def TDnet.process_trust_change_of_origin(train_identity, timestamp, reason_code, location_stanox)

      schedule = DailySchedule.find_by_train_identity_unique(train_identity)
      return Struct.new(:status, :message).new(:error, 'COO message for unactivated train ' + train_identity + " - ignoring") if schedule.nil?

      original_origin = schedule.origin

      new_origin_location = Tiploc.find_by_stanox(location_stanox)
      return Struct.new(:status, :message).new(:error, 'COO message for train ' + train_identity + ' has an unknown STANOX ' + location_stanox) if new_origin_location.nil?

      new_origin = schedule.locations.where(:tiploc_code => new_origin_location.tiploc_code).first
      return Struct.new(:status, :message).new(:error, 'COO message for train ' + train_identity + ' changes origin to ' + new_origin_location.tiploc_code + ' which is not in the schedule') if new_origin.nil?

      new_origin.location_type = 'LO'
      new_origin.save

      reached_new_origin = false

      schedule.locations.each do |calling_point|
        if calling_point.tiploc_code == new_origin.tiploc_code || reached_new_origin == true
          reached_new_origin = true
          next
        end
        calling_point.cancelled = true
        calling_point.cancellation_reason = reason_code
        calling_point.save
      end

      return Struct.new(:status, :message).new(:ok, "Changed origin of train #{train_identity} to #{new_origin.tiploc_code} from #{original_origin.tiploc_code} for reason #{reason_code}")

    end


    # Process a VSTP schedule creation.  Very Short Term Planning schedules
    # are created less than 48 hours before the train is due to run, and do
    # not appear in CIF extracts.

    def TDnet.process_vstp_message(msg)

      doc = Nokogiri::XML(msg) do |config|
        config.options = Nokogiri::XML::ParseOptions::NOBLANKS
      end

      vstp = Hash.new

      doc.children.each do |doc_child_1|

        raise "Expecting a VSTPCIFMsgv1 message" unless doc_child_1.name == "VSTPCIFMsgV1"

        doc_child_1.children.each do |doc_child_2|

          if doc_child_2.name == "Sender"

            # Parse the message sender details

            vstp[:sender_org] = doc_child_2.attributes['organisation'].text
            vstp[:sender_app] = doc_child_2.attributes['application'].text
            vstp[:sender_component] = doc_child_2.attributes['component'].text

          elsif doc_child_2.name == "schedule"

            vstp[:transaction_type] = doc_child_2.attributes['transaction_type'].text

            basic_schedule = Hash.new
            basic_schedule[:data_source] = "VSTP"
            basic_schedule[:uuid] = UUID.generate

            days_run = doc_child_2.attributes['schedule_days_runs'].text.split(//)

            basic_schedule[:runs_mo] = days_run[0]
            basic_schedule[:runs_tu] = days_run[1]
            basic_schedule[:runs_we] = days_run[2]
            basic_schedule[:runs_th] = days_run[3]
            basic_schedule[:runs_fr] = days_run[4]
            basic_schedule[:runs_sa] = days_run[5]
            basic_schedule[:runs_su] = days_run[6]

            mapping = { :train_uid => 'CIF_train_uid', :status => 'train_status', :runs_from => 'schedule_start_date', :runs_to => 'schedule_end_date', :bh_running => 'CIF_bank_holiday_running', :stp_indicator => 'CIF_stp_indicator', :ats_code => 'applicable_timetable' }

            # The CIF 'applicable timetable service' code does not appear for trains with a STP indicator of 'O' (STP Overlay to Permanent Schedule), so we must check each attributes presence before attempting to work with it

            mapping.each do |bs_attr, cif_attr|
              basic_schedule[bs_attr] = doc_child_2.attributes[cif_attr].text.strip if doc_child_2.attributes.has_key? cif_attr
            end

            doc_child_2.children.each do |doc_child_3|

              raise "Expecting a schedule_segment" unless doc_child_3.name == "schedule_segment"

              mapping = { :category => 'CIF_train_category', :train_identity => 'signalling_id', :headcode => 'CIF_headcode', :service_code => 'CIF_train_service_code', :power_type => 'CIF_power_type', :timing_load => 'CIF_timing_load', :speed => 'CIF_speed', :operating_characteristics => 'CIF_operating_characteristics', :train_class => 'CIF_train_class', :sleepers => 'CIF_sleepers', :reservations => 'CIF_reservations', :catering_code => 'CIF_catering_code', :service_branding => 'CIF_service_branding', :uic_code => 'uic_code', :atoc_code => 'atoc_code' }

              mapping.each do |bs_attr, cif_attr|
                basic_schedule[bs_attr] = doc_child_3.attributes[cif_attr].text
              end

              vstp[:location] = Array.new

              doc_child_3.children.each do |doc_child_4|

                raise "Expecting a schedule_location" unless doc_child_4.name == "schedule_location"

                # TODO: How are TIPLOC instances processed?

                mapping = { :arrival => 'scheduled_arrival_time', :public_arrival => 'public_arrival_time', :pass => 'scheduled_pass_time', :departure => 'scheduled_departure_time', :public_departure => 'public_departure_time', :platform => 'CIF_platform', :line => 'CIF_line', :path => 'CIF_path', :engineering_allowance => 'CIF_engineering_allowance', :pathing_allowance => 'CIF_pathing_allowance', :performance_allowance => 'CIF_performance_allowance' }
                location = Hash.new

                location[:basic_schedule_uuid] = basic_schedule[:uuid]

                mapping.each do |bs_attr, cif_attr|
                  location[bs_attr] = doc_child_4.attributes[cif_attr].text
                end

                # If the public arrival or public departure times are '00', get rid of them

                location[:public_arrival] = nil if location[:public_arrival] == "00" || location[:public_arrival].blank?
                location[:public_departure] = nil if location[:public_departure] == "00" || location[:public_departure].blank?


                # Split the CIF activities

                activities = TSDBExplorer::CIF::parse_activities(doc_child_4.attributes['CIF_activity'].text)

                activities.each do |k,v|
                  location[k] = v
                end

                if activities[:activity_tb] == true
                  location[:location_type] = "LO"
                elsif activities[:activity_tf] == true
                  location[:location_type] = "LT"
                else
                  location[:location_type] = "LI"

                  # VSTP schedules don't have a 'T' activity to indicate calling points, so we need to guess by looking for a public arrival or departure time

                  location[:activity_t] = true unless (location[:public_arrival].nil? && location[:public_departure].nil?)

                end

                location[:tiploc_code] = doc_child_4.children.children.first.attributes['tiploc_id'].text


                # Trim the last two characters from the public arrival and departure times, as these will only ever be whole minutes

                location[:public_arrival] = location[:public_arrival][0..3] unless location[:public_arrival].nil?
                location[:public_departure] = location[:public_departure][0..3] unless location[:public_departure].nil?


                # Replace the last two characters from an arrival, departure or pass time with a ' ' if a whole minute, or 'H' if a half-minute

                [ :arrival, :pass, :departure, :public_arrival, :public_departure ].each do |field_name|
                  next if location[field_name].nil?
                  location[field_name].sub!(/00$/, ' ') if location[field_name][4..5] == "00"
                  location[field_name].sub!(/30$/, 'H') if location[field_name][4..5] == "30"
                  location[field_name].strip!
                  location[field_name] = nil if location[field_name].blank?
                end


                # Tidy up the rest of the fields

                [ :platform, :line, :path ].each do |field_name|
                  location[field_name] = nil if location[field_name].blank?
                end

                vstp[:location] << location

              end

            end

            [:bh_running, :atoc_code, :service_branding, :catering_code, :operating_characteristics, :headcode, :sleepers].each do |f|
              basic_schedule[f.to_sym] = nil if basic_schedule[f.to_sym].blank?
            end

            [:reservations].each do |f|
              basic_schedule[f.to_sym] = nil if basic_schedule[f.to_sym] == "0"
            end

            vstp[:basic_schedule] = basic_schedule

          end

        end

      end

      BasicSchedule.create!(vstp[:basic_schedule])

      vstp[:location].each do |location|
        Location.create!(location)
      end

      return Struct.new(:status, :message).new(:ok, 'Created VSTP schedule for train ' + vstp[:basic_schedule][:train_uid] + ' running from ' + vstp[:basic_schedule][:runs_from] + ' to ' + vstp[:basic_schedule][:runs_to]  + ' as ' + vstp[:basic_schedule][:train_identity])

    end

  end

end

