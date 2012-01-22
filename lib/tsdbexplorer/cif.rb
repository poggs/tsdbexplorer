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

require 'tsdbexplorer/cif/classes.rb'

module TSDBExplorer

  module CIF

    # Process a record from a CIF file and return the data as a Hash

    def CIF.parse_record(record)

      unless record.blank?

        record_identity = record[0..1]

        # Process the record using the built-in Class parser

        if record_identity == "HD"
          TSDBExplorer::CIF::HeaderRecord.new(record)
        elsif record_identity == "BS"
          TSDBExplorer::CIF::BasicScheduleRecord.new(record)
        elsif record_identity == "BX"
          TSDBExplorer::CIF::BasicScheduleExtendedRecord.new(record)
        elsif record_identity == "TI" || record_identity == "TA" || record_identity == "TD"
          TSDBExplorer::CIF::TiplocRecord.new(record)
        elsif record_identity == "LO" || record_identity == "LI" || record_identity == "LT"
          TSDBExplorer::CIF::LocationRecord.new(record)
        elsif record_identity == "AA"
          TSDBExplorer::CIF::AssociationRecord.new(record)
        elsif record_identity == "CR"
          TSDBExplorer::CIF::ChangeEnRouteRecord.new(record)
        elsif record_identity == "ZZ"
          # End of File
        else
          Struct.new(:status, :message).new(:error, "Unsupported record type '#{record_identity}' found")
        end

      end

    end


    # Process a CIF file

    def CIF.process_cif_file(filename)

      return Struct.new(:status, :message).new(:error, "CIF file #{filename} does not exist") unless File.exist? filename
      return Struct.new(:status, :message).new(:error, "CIF file #{filename} not readable") unless File.readable? filename

      cif_data = File.open(filename)
      file_size = File.size(filename)

      puts "\nProcessing #{filename} (#{file_size} bytes)" unless ::Rails.env == "test"


      # The first line of the CIF file must be an HD record

      header_data = TSDBExplorer::CIF::parse_record(cif_data.first)

      return header_data if header_data.is_a? Class
      return Struct.new(:status, :message).new(:error, "No CIF HD record found at the beginning of #{filename}") unless header_data.is_a? TSDBExplorer::CIF::HeaderRecord


      # If this is extract references a 'last file reference', ensure the
      # last file imported has the same identity

      last_file_record = CifFile.last

      if header_data.update_indicator == "F"

        num_basic_schedules = BasicSchedule.count
        num_locations = Location.count
        num_tiplocs = Tiploc.count

        if(num_basic_schedules != 0 || num_locations != 0 || num_tiplocs != 0)
          return Struct.new(:status, :message).new(:error, "Full extract #{header_data.current_file_ref} may only be applied to an empty database - there are #{num_tiplocs} TIPLOCs and #{num_basic_schedules} schedules")
        end

      elsif last_file_record.nil? || (last_file_record.file_ref != header_data.last_file_ref)
        return Struct.new(:status, :message).new(:error, "CIF update #{header_data.current_file_ref} must be applied after file #{header_data.last_file_ref}")
      end


      # Display data from the CIF header record

      unless ::Rails.env == "test"
        puts "+--------------------------------------------------------------------------"
        puts "| Importing CIF file #{header_data.current_file_ref} for #{header_data.mainframe_username}"
        puts "| Generated on #{header_data.date_of_extract} at #{header_data.time_of_extract}"
        puts "| Data from #{header_data.user_extract_start_date} to #{header_data.user_extract_end_date}"
        puts "+--------------------------------------------------------------------------"
      end


      # Create a CifFile record, which will be saved when importing is complete

      if header_data.date_of_extract[4..5].to_i >= 70
        century = '19'
      else
        century = '20'
      end

      extract_timestamp = Time.parse(header_data.date_of_extract[0..1] + "-" + header_data.date_of_extract[2..3] + "-" + century + header_data.date_of_extract[4..5] + " " + header_data.time_of_extract[0..1] + ":" + header_data.time_of_extract[2..3] + ":00")
       
      start_date = Date.parse(header_data.user_extract_start_date[0..1] + "-" + header_data.user_extract_start_date[2..3] + "-" + century + header_data.user_extract_start_date[4..5])
      end_date = Date.parse(header_data.user_extract_end_date[0..1] + "-" + header_data.user_extract_end_date[2..3] + "-" + century + header_data.user_extract_end_date[4..5])

      cif_file_record = CifFile.new(:file_ref => header_data.current_file_ref, :extract_timestamp => extract_timestamp, :start_date => start_date, :end_date => end_date, :update_indicator => header_data.update_indicator, :file_mainframe_identity => header_data.file_mainframe_identity, :mainframe_username => header_data.mainframe_username)


      # Initialize a set of statistics to return to the calling function

      stats = {:schedule=>{:insert=>0, :amend=>0, :delete=>0}, :tiploc=>{:insert=>0, :amend=>0, :delete=>0}, :association=>{:insert=>0, :amend=>0, :delete=>0}}

      pending = { 'Tiploc' => { :cols => [ :tiploc_code, :nalco, :nalco_four, :tps_description, :stanox, :crs_code, :description ], :rows => [] },
                  'BasicSchedule' => { :cols => [ :uuid, :train_uid, :train_identity_unique, :runs_from, :runs_to, :runs_mo, :runs_tu, :runs_we, :runs_th, :runs_fr, :runs_sa, :runs_su, :bh_running, :status, :category, :train_identity, :headcode, :service_code, :portion_id, :power_type, :timing_load, :speed, :operating_characteristics, :train_class, :sleepers, :reservations, :catering_code, :service_branding, :stp_indicator, :uic_code, :atoc_code, :ats_code, :rsid, :data_source ], :rows => [] },
                  'Location' => { :cols => [ :basic_schedule_uuid, :location_type, :seq, :tiploc_code, :tiploc_instance, :arrival, :public_arrival, :pass, :departure, :public_departure, :platform, :line, :path, :engineering_allowance, :pathing_allowance, :performance_allowance, :activity_tb, :activity_tf, :activity_d, :activity_u, :activity_n, :activity_r, :activity_s, :activity_t, :activity_rm, :activity_op ], :rows => [] } }
      start_time = Time.now


      # Set up a progress bar

      require 'progressbar' # TODO: Eliminate having to 'require' progressbar
      pbar = ProgressBar.new(header_data.current_file_ref, file_size) unless ::Rails.env == "test"


      # Iterate through the CIF file and process each record

      while(!cif_data.eof)

        record = TSDBExplorer::CIF::parse_record(cif_data.gets)

        return record if record.is_a? Struct

        pbar.set(cif_data.pos) unless ::Rails.env == "test"

        if record.is_a? TSDBExplorer::CIF::TiplocRecord

          if record.action == "I"

            # TIPLOC Insert

            data = []
            pending['Tiploc'][:cols].each do |column|
              data << record.send(column)
            end
            pending['Tiploc'][:rows] << data

            stats[:tiploc][:insert] = stats[:tiploc][:insert] + 1

          elsif record.action == "A"

            # TIPLOC Amend

            return Struct.new(:status, :message).new(:error, "TIPLOC Amend (TA) record not allowed in a CIF full extract") if header_data.update_indicator == "F"

            amend_record = Tiploc.find_by_tiploc_code(record.tiploc_code)
            return Struct.new(:status, :message).new(:error, "Unknown TIPLOC '#{record.tiploc_code}' found in TA record") if amend_record.nil?

            [ :tiploc_code, :nalco, :nalco_four, :tps_description, :stanox, :crs_code, :description ].each do |field|
              amend_record[field] = record.send(field)
            end

            amend_record.save

            stats[:tiploc][:amend] = stats[:tiploc][:amend] + 1

          elsif record.action == "D"

            # TIPLOC Delete

            return Struct.new(:status, :message).new(:error, "TIPLOC Delete (TD) record not allowed in a CIF full extract") if header_data.update_indicator == "F"

            deletion_record = Tiploc.find_by_tiploc_code(record.tiploc_code)
            return Struct.new(:status, :message).new(:error, "Unknown TIPLOC '#{record.tiploc_code}' found in TD record") if deletion_record.nil?
            deletion_record.destroy

            stats[:tiploc][:delete] = stats[:tiploc][:delete] + 1

          end

        elsif record.is_a? TSDBExplorer::CIF::BasicScheduleRecord

          # Check if we have any pending TIPLOCs to insert, and if so,
          # process them now

          pending = process_pending(pending) if pending['Tiploc'][:rows].count > 0


          # If we are processing a Revise record, delete the schedule to
          # which the revision applies, change the transaction type to New
          # and process normally

          if record.transaction_type == "R"

            return Struct.new(:status, :message).new(:error, "Basic Schedule revise (BSR) record not allowed in a CIF full extract") if header_data.update_indicator == "F"

            deletion_record = BasicSchedule.find(:first, :conditions => { :train_uid => record.train_uid, :runs_from => record.runs_from })
            return Struct.new(:status, :message).new(:error, "Unknown schedule for UID #{record[:train_uid]} on #{record[:runs_from]}") if deletion_record.nil?

            deletion_record.destroy

          end


          loc_records = Array.new

          if record.transaction_type == "N" || record.transaction_type == "R"

            # Schedule cancellations (BS records with the STP indicator set to
            # 'C') have no locations, so must be processed separately

            bs_record = Hash.new

            if record.stp_indicator != "C"

              # Generate a UUID  for this BasicSchedule record

              uuid = UUID.generate
              record.uuid = uuid


              # Read in the associated BX record and merge the data in to the BS record

              bx_record = TSDBExplorer::CIF::parse_record(cif_data.gets)
              record.merge_bx_record(bx_record)


              # Read in all records up to and including the next LT record

              location_record = TSDBExplorer::CIF::LocationRecord.new

              seq = 10

              while(1)

                cif_record = cif_data.gets
                next if cif_record[0..1] == "CR" # TODO: Remove change-en-route hack
                location_record = TSDBExplorer::CIF::parse_record(cif_record)
                location_record.seq = seq
                Struct.new(:status, :message).new("Record was parsed as a '#{location_record.class}', expecting a TSDBExplorer::CIF::LocationRecord") unless location_record.is_a? TSDBExplorer::CIF::LocationRecord
                location_record.basic_schedule_uuid = uuid
                loc_records << location_record

                break if location_record.location_type == "LT"

                seq = seq + 10

              end

              if record.transaction_type == "N"
                stats[:schedule][:insert] = stats[:schedule][:insert] + 1
              else
                stats[:schedule][:amend] = stats[:schedule][:amend] + 1
              end

            end

          elsif record.transaction_type == "D"

            return Struct.new(:status, :message).new(:error, "Basic Schedule Delete (BSD) record not allowed in a CIF full extract") if header_data.update_indicator == "F"

            deletion_record = BasicSchedule.find(:first, :conditions => { :train_uid => record.train_uid, :runs_from => record.runs_from })
            return Struct.new(:status, :message).new(:error, "Unknown schedule for UID #{record[:train_uid]} on #{record[:runs_from]}") if deletion_record.nil?

            deletion_record.destroy

            stats[:schedule][:delete] = stats[:schedule][:delete] + 1

          else

            return Struct.new(:status, :message).new(:error, "Unknown BS transaction type #{record.transaction_type} found")

          end



          # If location records exist for this schedule (as they might not
          # if this is a cancellation), push them on to the pending INSERT
          # queue

          unless loc_records == []

            loc_records.each do |r|
              data = []
              pending['Location'][:cols].each do |column|
                data << r.send(column) if r.respond_to? column
              end
              pending['Location'][:rows] << data
            end

          end


          # Push any the schedules on to the pending INSERT queue

          if bs_record

            data = []
            pending['BasicSchedule'][:cols].each do |column|
              data << record.send(column) if record.respond_to? column
            end

            pending['BasicSchedule'][:rows] << data

            if pending['BasicSchedule'][:rows].count > 1000
              pending = process_pending(pending)
            end

          end

        end

      end

      pbar.finish unless ::Rails.env == "test"

      pending = process_pending(pending)


      # Save the record of this CIF file

      cif_file_record.save


      # Update the Redis caches

      TSDBExplorer::Realtime::cache_location_database


      # Calculate stats

      stats_text = "Schedules: #{stats[:schedule][:insert]} inserted, #{stats[:schedule][:amend]} amended, #{stats[:schedule][:delete]} deleted.  TIPLOCs: #{stats[:tiploc][:insert]} inserted, #{stats[:tiploc][:amend]} amended, #{stats[:tiploc][:delete]} deleted.  Associations: #{stats[:association][:insert]} inserted, #{stats[:association][:amend]} amended, #{stats[:association][:delete]} deleted"

      return Struct.new(:status, :message).new(:ok, "Import complete. " + stats_text)

    end


    # Parse a list of CIF activities in to a hash, with activities present in the list represented by true values in the hash

    def CIF.parse_activities(activity_list)

      activities = ['AE', 'BL', '-D', 'HH', 'KC', 'KE', 'KF', 'KS', 'OP', 'OR', 'PR', 'RM', 'RR', '-T', 'TB', 'TF', 'TS', 'TW', '-U', 'A', 'C', 'D', 'E', 'G', 'H', 'K', 'L', 'N', 'R', 'S', 'T', 'U', 'W', 'X']
      processed_activities = Hash.new

      activities.each do |z|
        processed_activities["activity_#{z}".sub(/\-/, 'minus').downcase.to_sym] = false
      end

      activity_list.strip!

      while(activity_list.length > 0)
      
        activity_list.lstrip!

        changed = nil

        activities.each do |activity|
          m = activity_list.match("^#{activity}(.*)")
          unless m.nil?
            processed_activities["activity_#{activity}".sub(/\-/, 'minus').downcase.to_sym] = true
            activity_list = m[1]
            changed = true
            break
          end
        end

        raise "Unknown CIF activity '#{activity_list}'" if changed.nil?

      end

      return processed_activities

    end


    def CIF.process_pending(pending)

      # Process all the pending transactions

      orig_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 6

      pending.keys.each do |model_object|

        eval(model_object).import pending[model_object][:cols], pending[model_object][:rows], :validate => false

        pending[model_object][:rows] = []

      end

      ActiveRecord::Base.logger.level = orig_level

      return pending

    end


    # Convert an origin time to an origin code, used to construct a
    # 10-character Unique Train Identity

    def CIF.departure_to_code(time)

      hour = time[0..1].to_i
      minute = time[2..3].to_i
      offset = hour * 2 + (minute / 30)

      xlate = "00112233445566ABCDEFGHIJKLMNOPQRSTUVWXYYZZ778899".split(//)

      return xlate[offset]

    end


    # Calculate the next mainframe file reference, given the last processed

    def CIF.next_file_reference(last_file)

      next_file = nil

      if last_file[-1..-1] == "Z"
        next_file = last_file[0..5] + "A"
      else
        next_file = last_file.next
      end

    end

  end

end
