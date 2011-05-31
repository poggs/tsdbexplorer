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

  # Returns true if the train identity supplied is in the correct format,
  # i.e. <number><letter><number><number>. This does *not* indicate whether
  # the train identity refers to a service, merely whether the identity is
  # formatted correctly.

  def TSDBExplorer.validate_train_identity(train_identity)

    if train_identity.nil? || !train_identity.match(/\d[A-Za-z]\d\d/)
      return false
    else
      return true
    end

  end


  # Returns true if the train UID supplied is in the correct format, i.e.
  # <letter><number><number><number><number><number>.  This does *not* indicate
  # whether the train UID refers to a service, merely whether the identity is
  # formatted correctly.

  def TSDBExplorer.validate_train_uid(train_uid)

    if train_uid.nil? || !train_uid.match(/[A-Za-z]\d\d\d\d\d/)
      return false
    else
      return true
    end

  end


  # Converts a string in the format YYMMDD in to a string in the format
  # YYYY-MM-DD.  If the YY value supplied is between 60 and 99 inclusive,
  # '19' is prepended, otherwise '20' is prepended, i.e. years between
  # 60 and 99 inclusive are assumed to be in the 1900s.

  def TSDBExplorer.yymmdd_to_date(date)

    formatted_date = nil

    unless date.nil? || date.blank?

      yy = date.slice(0,2).to_i
      mm = date.slice(2,2).to_i
      dd = date.slice(4,2).to_i

      if yy >= 60 && yy <= 99
        century = 19
      else
        century = 20
      end

      formatted_date = century.to_s + yy.to_s.rjust(2,"0") + "-" + mm.to_s.rjust(2,"0") + "-" + dd.to_s.rjust(2,"0")

    end

    return formatted_date

  end


  # Converts a string in the format DDMMYY in to a string in the format
  # YYYY-MM-DD.  If the YY value supplied is between 60 and 99 inclusive,
  # '19' is prepended, otherwise '20' is prepended, i.e. years between
  # 60 and 99 inclusive are assumed to be in the 1900s.

  def TSDBExplorer.ddmmyy_to_date(date)

    dd = date.slice(0,2).to_i
    mm = date.slice(2,2).to_i
    yy = date.slice(4,2).to_i

    if yy >= 60 && yy <= 99
      century = 19
    else
      century = 20
    end

    return century.to_s + yy.to_s.rjust(2,"0") + "-" + mm.to_s.rjust(2,"0") + "-" + dd.to_s.rjust(2,"0")

  end


  # Converts a string in the format DDMMYY in to a string in the format
  # YYMMDD.

  def TSDBExplorer.ddmmyy_to_yymmdd(date)

    dd = date.slice(0,2).to_i
    mm = date.slice(2,2).to_i
    yy = date.slice(4,2).to_i

    return yy.to_s.rjust(2,"0") + mm.to_s.rjust(2,"0") + dd.to_s.rjust(2,"0")

  end


  # Convert a date in YYYY-MM-DD format, and a time in HHMM format
  # (optionally with the letter H appended to indicate 30 seconds), to a
  # Time object

  def TSDBExplorer.normalise_datetime(datetime)

    normal_datetime = nil

    unless datetime.nil?
      date,time = datetime.split(" ")
      normal_datetime = Time.parse(date + " " + TSDBExplorer.normalise_time(time))
    end
    
    return normal_datetime

  end  


  # Convert a time in HHMM format (optionally with the letter H appended to
  # indicate 30 seconds), to HH:MM:SS format

  def TSDBExplorer.normalise_time(time)

    normal_time = nil

    unless time.nil?
      normal_time = time.slice(0,2) + ":" + time.slice(2,2)
      normal_time = normal_time + ":30" if time.slice(4,1) == "H"
    end

    return normal_time

  end


  # Convert an allowance time in the format M (optionally with the letter H appended to indicate 30 seconds) in to an integer number of seconds

  def TSDBExplorer.normalise_allowance_time(time)

    normal_time = nil

    unless time.nil?
      normal_time = time.to_i * 60
      if time.last == "H"
        normal_time = normal_time + 30
      end
    end

    return normal_time

  end


  # Parse and validate a File Mainframe Identity field from a CIF 'HD'
  # record.  If the data is valid, it returns a hash with :username and
  # :extract_date keys.  If the data is not valid, it returns a hash with a
  # single :error key.

  def TSDBExplorer.cif_parse_file_mainframe_identity(mainframe_identity)

    data = Hash.new

    if mainframe_identity.match(/TPS.U(.{6}).PD(.{6})/).nil?
      data[:error] = "File Mainframe Identity '#{mainframe_identity}' is not valid - must start with TPS.U, be followed by six characters, then .PD and a further six characters"
    end

    username_match = $1
    extract_date_match = $2

    unless data.has_key? :error

      username = username_match.match(/([CD]F\w{4})/)

      if username.nil?
        data[:error] = "Username '#{username}' is not valid - must start with CF or DF and be followed by four characters"
      else
        data[:username] = $1
      end

    end


    unless data.has_key? :error

      extract_date = extract_date_match.match(/(\d{6})/)

      if extract_date.nil?
        data[:error] = "Extract date '#{extract_date}' is not valid - must be six numerics"
      else
        data[:extract_date] = $1
      end

    end

    return data

  end


  # Process a range of dates and return a list of dates falling on the days
  # specified by day_mask - a binary field where the first position is
  # Monday, second is Tuesday and so on.

  def TSDBExplorer.date_range_to_list(start_date, end_date, day_mask)

    # Convert the day_mask in to a list of Date day numbers

    cif_days = day_mask.split(//)
    trans_list = [ 1, 2, 3, 4, 5, 6, 0 ]
    ruby_days = Array.new

    count = 0

    cif_days.each do |cif_pos|

      if cif_pos == "1"
        ruby_days.push(trans_list[count])
      end

      count = count + 1

    end


    # Iterate through all the dates in the range and add each date whose
    # weekday falls on a day specified in ruby_days to an array

    date_list = Array.new

    current_date = Date.parse(start_date)
    range_end_date = Date.parse(end_date)

    while current_date <= range_end_date

      if ruby_days.include? current_date.wday
        date_list.push current_date.to_s
      end

      current_date = current_date.next

    end

    return date_list

  end


  # Calculate the next mainframe file reference, given the last processed

  def TSDBExplorer.next_file_reference(last_file)

    next_file = nil

    if last_file[-1..-1] == "Z"
      next_file = last_file[0..5] + "A"
    else
      next_file = last_file.next
    end

  end


  module CIF

    # Process a record from a CIF file and return the data as a Hash

    def CIF.parse_record(record)

      result = Hash.new
      result[:record_identity] = record[0..1]

      structure = case result[:record_identity]
        when "HD"
          { :delete => [ :spare ], :format => [ [ :file_mainframe_identity, 20 ], [ :date_of_extract, 6 ], [ :time_of_extract, 4 ], [ :current_file_ref, 7 ], [ :last_file_ref, 7 ], [ :update_indicator, 1 ], [ :version, 1 ], [ :user_extract_start_date, 6 ], [ :user_extract_end_date, 6], [ :spare, 20 ] ] }
        when "TI"
          { :delete => [ :capitals_identification, :nlc_check_character, :po_mcp_code, :spare ], :strip => [ :tiploc_code, :tps_description, :description ], :format => [ [ :tiploc_code, 7 ], [ :capitals_identification, 2 ], [ :nalco, 6 ], [ :nlc_check_character, 1 ], [ :tps_description, 26 ], [ :stanox, 5 ], [ :po_mcp_code, 4 ], [ :crs_code, 3 ], [ :description, 16 ], [ :spare, 8 ] ] }
        when "TA"
          { :delete => [ :capitals_identification, :nlc_check_character, :po_mcp_code, :spare ], :strip => [ :tiploc_code, :tps_description, :description ], :format => [ [ :tiploc_code, 7 ], [ :capitals_identification, 2 ], [ :nalco, 6 ], [ :nlc_check_character, 1 ], [ :tps_description, 26 ], [ :stanox, 5 ], [ :po_mcp_code, 4 ], [ :crs_code, 3 ], [ :description, 16 ], [ :new_tiploc, 7 ], [ :spare, 1 ] ] }
        when "TD"
          { :delete => [ :spare ], :format => [ [ :tiploc_code, 7 ], [ :spare, 71 ] ] }
        when "AA"
          { :delete => [ :spare ], :format => [ [ :transaction_type, 1 ], [ :main_train_uid, 6 ], [ :assoc_train_uid, 6 ], [ :association_start_date, 6 ], [ :association_end_date, 6 ], [ :association_days, 7 ], [ :category, 2 ], [ :date_indicator, 1 ], [ :location, 7 ], [ :base_location_suffix, 1 ], [ :assoc_location_suffix, 1 ], [ :diagram_type, 1 ], [ :assoc_type, 1 ], [ :spare, 31 ], [ :stp_indicator, 1 ] ] }
        when "BS"
          { :delete => [ :spare, :course_indicator ], :convert_yymmdd => [ :runs_from, :runs_to ], :format => [ [ :transaction_type, 1 ], [ :train_uid, 6 ], [ :runs_from, 6 ], [ :runs_to, 6 ], [ :days_run, 7 ], [ :bh_running, 1 ], [ :status, 1 ], [ :category, 2 ], [ :train_identity, 4 ], [ :headcode, 4 ], [ :course_indicator, 1 ], [ :service_code, 8 ], [ :portion_id, 1 ], [ :power_type, 3 ], [ :timing_load, 4 ], [ :speed, 3 ], [ :operating_characteristics, 6 ], [ :train_class, 1 ], [ :sleepers, 1 ], [ :reservations, 1 ], [ :connection_indicator, 1 ], [ :catering_code, 4 ], [ :service_branding, 4 ], [ :spare, 1 ], [ :stp_indicator, 1 ] ] }
        when "BX"
          { :delete => [ :spare ], :format => [ [ :traction_class, 4 ], [ :uic_code, 5 ], [ :atoc_code, 2 ], [ :applicable_timetable, 1 ], [ :rsid, 8 ], [ :data_source, 1 ], [ :spare, 57 ] ] }
        when "LO"
          { :delete => [ :spare ], :strip => [ :tiploc_code, :platform, :line ], :format => [ [ :tiploc_code, 7 ], [ :tiploc_instance, 1 ], [ :departure, 5 ], [ :public_departure, 4 ], [ :platform, 3 ], [ :line, 3 ], [ :engineering_allowance, 2 ], [ :pathing_allowance, 2 ], [ :activity, 12 ], [ :performance_allowance, 2 ], [ :spare, 37 ] ] }
        when "LI"
          { :delete => [ :spare ], :strip => [ :tiploc_code, :platform, :line ], :format => [ [ :tiploc_code, 7 ], [ :tiploc_instance, 1 ], [ :arrival, 5 ], [ :departure, 5 ], [ :pass, 5 ], [ :public_arrival, 4 ], [ :public_departure, 4 ], [ :platform, 3 ], [ :line, 3 ], [ :path, 3 ], [ :activity, 12 ], [ :engineering_allowance, 2 ], [ :pathing_allowance, 2 ], [ :performance_allowance, 2 ], [ :spare, 20 ] ] }
        when "CR"
          { :delete => [ :spare ], :strip => [ :tiploc_code, :line ], :format => [ [ :tiploc_code, 7 ], [ :tiploc_instance, 1 ], [ :category, 2 ], [ :train_identity, 4 ], [ :headcode, 4 ], [ :course_indicator, 1 ], [ :service_code, 8 ], [ :portion_id, 1 ], [ :power_type, 3 ], [ :timing_load, 4 ], [ :speed, 3 ], [ :operating_characteristics, 6 ], [ :train_class, 1 ], [ :sleepers, 1 ], [ :reservations, 1 ], [ :connection_indicator, 1 ], [ :catering_code, 4 ], [ :service_branding, 4 ], [ :traction_class, 4 ], [ :uic_code, 5 ], [ :rsid, 8 ], [ :spare, 5 ] ] }
        when "LT"
          { :delete => [ :spare ], :strip => [ :tiploc_code, :platform, :line ], :format => [ [ :tiploc_code, 7 ], [ :tiploc_instance, 1 ], [ :arrival, 5 ], [ :public_arrival, 4 ], [ :platform, 3 ], [ :path, 3 ], [ :activity, 12 ], [ :spare, 43 ] ] }
        when "ZZ"
          { :delete => [], :format => [] }
        else
          raise "Unsupported record type '#{result[:record_identity]}'"
      end


      # Slice up the record in to its fields as defined above, starting at
      # column 2, as we already have the record identity parsed

      pos = 2

      structure[:format].each do |field|
        field_name = field[0].to_sym
        value = record.slice(pos, field[1])
        result[field_name] = value.blank? ? nil : value
        pos = pos + field[1]
      end


      # Delete any unnecessary fields

      structure[:delete].each do |field|
        result.delete field
      end


      # Reformat certain fields if required

      if structure.has_key? :convert_yymmdd
        structure[:convert_yymmdd].each do |field|
          result[field] = TSDBExplorer::yymmdd_to_date(result[field])
        end
      end

      if structure.has_key? :strip
        structure[:strip].each do |field|
          result[field].strip! unless result[field].nil?
        end
      end

      return result

    end



    def CIF.process_cif_file(filename)

      cif_data = File.open(filename)
      puts "Processing #{filename}"


      # The first line of the CIF file must be an HD record

      header_data = TSDBExplorer::CIF::parse_record(cif_data.first)

      raise "Expecting an HD record at the start of #{filename} - found a '#{header_data[:record_identity]}' record" unless header_data[:record_identity] == "HD"


      # Validate the HD record

      file_mainframe_identity_data = TSDBExplorer.cif_parse_file_mainframe_identity(header_data[:file_mainframe_identity])

      raise file_mainframe_identity_data[:error] if file_mainframe_identity_data.has_key? :error

      puts "-----------------------------------------------------------------------------"
      puts "      Mainframe ID : #{header_data[:file_mainframe_identity]}"
      puts "              User : #{file_mainframe_identity_data[:username]}"
      puts "      Extract date : #{header_data[:date_of_extract]}"
      puts "      Extract time : #{header_data[:time_of_extract]}"
      puts "    File reference : #{header_data[:current_file_ref]}"
      puts "    Last reference : #{header_data[:last_file_ref]}"
      puts "  Update indicator : #{header_data[:update_indicator]}"
      puts "       CIF version : #{header_data[:version]}"
      puts "     Extract start : #{header_data[:user_extract_start_date]}"
      puts "       Extract end : #{header_data[:user_extract_end_date]}"
      puts "-----------------------------------------------------------------------------"

      end_of_data = 0
      line_number = 0

      pending_trans = Hash.new
      pending_trans['Tiploc'] = Array.new
      pending_trans['Association'] = Array.new

      stats = { :tiploc => { :insert => 0, :amend => 0, :delete => 0 },
                :association => { :insert => 0, :amend => 0, :delete => 0 },
                :schedule => { :insert => 0, :amend => 0, :delete => 0 } }

      schedule = Array.new

      cif_data.each do |record|

        # Process any pending transactions

        pending_trans.keys.each do |model|
          unless pending_trans[model].blank?
            eval(model).import pending_trans[model]
            pending_trans[model] = Array.new
          end
        end

        next if end_of_data == 1 && record.blank?
        raise "Data found after ZZ record" if end_of_data == 1

        line_number = line_number + 1

        data = TSDBExplorer::CIF::parse_record(record)

        if data[:record_identity] == "ZZ"

          end_of_data == 1

        elsif data[:record_identity] == "TI"

          # TI: TIPLOC Insert

          data.delete :record_identity

          pending_trans['Tiploc'] << Tiploc.new(data)

          stats[:tiploc][:insert] = stats[:tiploc][:insert] + 1

        elsif data[:record_identity] == "TA"

          # TA: TIPLOC Amend

          raise "Line #{line_number}: TIPLOC Amend (TA) record found in a full extract" if header_data[:update_indicator] == "F"

          data.delete :record_identity

          model_object = Tiploc.find_by_tiploc_code(data[:tiploc_code])

          if model_object.nil?
            return { :error => "TIPLOC #{data[:tiploc_code]} not found in TA record at line #{line_number}"}
          else

            # Check if the TIPLOC has changed

            unless data[:new_tiploc].nil?
              data[:tiploc_code] = data[:new_tiploc]
            end

            data.delete :new_tiploc

            model_object.attributes = data
            model_object.save
            stats[:tiploc][:amend] = stats[:tiploc][:amend] + 1

          end

        elsif data[:record_identity] == "TD"

          # TD: TIPLOC Delete

          raise "Line #{line_number}: TIPLOC Delete (TD) record found in a full extract" if header_data[:update_indicator] == "F"

          model_object = Tiploc.find_by_tiploc_code(data[:tiploc_code].strip)

          if model_object.nil?
            return { :error => "TIPLOC #{data[:tiploc_code]} not found in TD record at line #{line_number}" }
          else
            model_object.delete
            stats[:tiploc][:delete] = stats[:tiploc][:delete] + 1
          end

        elsif data[:record_identity] == "AA"

          # AA: Association

          data[:association_start_date] = TSDBExplorer.yymmdd_to_date(data[:association_start_date])
          data[:association_end_date] = TSDBExplorer.yymmdd_to_date(data[:association_end_date]) unless data[:transaction_type] == "D"

          if data[:transaction_type] == "N"

            # New record

            data.delete :record_identity
            data.delete :transaction_type


            # Expand the date range

            raise if data[:association_end_date] == "999999"

            date_range = TSDBExplorer.date_range_to_list(data[:association_start_date], data[:association_end_date], data[:association_days])
            data.delete :association_start_date
            data.delete :association_end_date
            data.delete :association_days

            date_range.each do |assoc_date|

              data[:date] = assoc_date
              pending_trans['Association'] << Association.new(data)
              stats[:association][:insert] = stats[:association][:insert] + 1

            end

          elsif data[:transaction_type] == "D"

            # Delete record

            model_object = Association.find(:first, :conditions => { :main_train_uid => data[:main_train_uid], :assoc_train_uid => data[:assoc_train_uid], :date => data[:association_start_date] })
            model_object.delete

            stats[:association][:delete] = stats[:association][:delete] + 1

          elsif data[:transaction_type] == "R"

            # Revise record

            date_range = TSDBExplorer.date_range_to_list(data[:association_start_date], data[:association_end_date], data[:association_days])

            date_range.each do |assoc_date|

              model_object = Association.find(:first, :conditions => { :main_train_uid => data[:main_train_uid], :assoc_train_uid => data[:assoc_train_uid], :date => assoc_date })

              raise "Line #{line_number}: Failed to find association between #{data[:main_train_uid]} and #{data[:assoc_train_uid]} on #{assoc_date}" if model_object.nil?

              model_object.delete
              stats[:association][:amend] = stats[:association][:amend] + 1

            end

          else

            raise "Invalid transaction type '#{data[:transaction_type]}' for AA record at line #{line_number}"

          end

        elsif data[:record_identity] == "BS"

          # BS: Basic Schedule

          raise "Line #{line_number}: Basic Schedule (BS) revise record found in a full extract" if header_data[:update_indicator] == "F" && data[:transaction_type] == "R"
          raise "Line #{line_number}: Basic Schedule (BS) delete record found in a full extract" if header_data[:update_indicator] == "F" && data[:transaction_type] == "D"
          raise "Line #{line_number}: Basic Schedule (BS) record found without a prior Location Terminate (LT) record" if schedule.nil?

          schedule = Hash.new
          data.delete :record_identity
          schedule[:basic] = data

          if schedule[:basic][:transaction_type] == "D"

            # Delete record

            TSDBExplorer::CIF::delete_bs_record(schedule[:basic], stats)

          elsif schedule[:basic][:transaction_type] == "R"

            # Revise record

            TSDBExplorer::CIF::delete_bs_record(schedule[:basic], stats)

            # NOTE: The new schedule is processed later alongside BS New record processing.

          end

        elsif data[:record_identity] == "BX"

          # BX: Basic Schedule Extended

          raise "Line #{line_number}: More than one Basic Schedule Extended (BX) found for this schedule" if schedule.has_key? :basic_schedule_extended

          data.delete :record_type
          schedule[:basic_schedule_extended] = data

        elsif data[:record_identity] == "LO"

          # LO: Location Origin

          raise "Line #{line_number}: More than one Location Origin (LO) found for this schedule" if schedule.has_key? :origin

          data[:location_type] = data[:record_identity]
          data.delete :record_identity
          schedule[:origin] = data

        elsif data[:record_identity] == "LI"

          # LI: Location Intermediate

          data[:location_type] = data[:record_identity]
          data.delete :record_identity

          schedule[:intermediate] = Array.new unless schedule.has_key? :intermediate
          schedule[:intermediate] << data

        elsif data[:record_identity] == "CR"

          # CR: Change-en-Route

          data[:location_type] = data[:record_identity]
          data.delete :record_identity

        elsif data[:record_identity] == "LT"

          # LT: Location Teminate

          raise "Line #{line_number}: More than one Location Terminate (LT) found for this schedule" if schedule.has_key? :terminate

          data[:location_type] = data[:record_identity]
          data.delete :record_identity
          schedule[:terminate] = data

          # Verify we have the minimum set of records for this schedule

          raise "Line #{line_number}: Schedule invalid - expected a minimum of one BS, one LO and one LT record" unless ((schedule.has_key? :basic) && (schedule.has_key? :origin) && (schedule.has_key? :terminate))

          if schedule[:basic][:transaction_type] == "N" || schedule[:basic][:transaction_type] == "R"

            # Process the schedule

            action_type = :insert

            if schedule[:basic][:transaction_type] == "R" || schedule[:basic][:stp_indicator] == "O"
              action_type = :amend
            end

            schedule[:basic].delete :transaction_type

            # If this is an STP Overlay to the permanent schedule, delete the old records before adding new ones

            if schedule[:basic][:stp_indicator] == "O"
              stats = TSDBExplorer::CIF::delete_bs_record(schedule[:basic], stats)
            end

            date_range = TSDBExplorer.date_range_to_list(schedule[:basic][:runs_from], schedule[:basic][:runs_to], schedule[:basic][:days_run])
            schedule[:basic].delete :runs_from
            schedule[:basic].delete :runs_to
            schedule[:basic].delete :days_run

            # TODO: Integrate Bank Holiday logic in to date_range_to_list
            schedule[:basic].delete :bh_running

            schedule[:basic].delete :stp_indicator

            date_range.each do |run_date|

              # Add a BasicSchedule for each date in the date range

              schedule[:basic][:run_date] = run_date
              schedule[:basic][:uuid] = UUID.generate
              pending_trans['BasicSchedule'] = Array.new unless pending_trans.has_key? 'BasicSchedule'
              pending_trans['BasicSchedule'] << BasicSchedule.new(schedule[:basic])

              stats[:schedule][action_type] = stats[:schedule][action_type] + 1


              # Add an originating location

              origin_clone = schedule[:origin].clone
              origin_clone[:basic_schedule_uuid] = schedule[:basic][:uuid]
              origin_clone[:departure] = TSDBExplorer::normalise_datetime(run_date + " " + origin_clone[:departure])
              origin_clone[:public_departure] = TSDBExplorer::normalise_datetime(run_date + " " + origin_clone[:public_departure])

              Location.create!(origin_clone)


              # Add an intermediate location

              intermediate_clone = schedule[:intermediate].nil? ? [] : schedule[:intermediate].clone

              intermediate_clone.each do |template_location|

                location = template_location.clone


                # If this location has the public arrival and public departure set to 0000, it contains a passing time only

                location[:public_arrival] = nil if location[:public_arrival].nil? || location[:public_arrival] == "0000"
                location[:public_departure] = nil if location[:public_departure].nil? || location[:public_departure] == "0000"


                location[:arrival] = TSDBExplorer::normalise_datetime(run_date + " " + location[:arrival]) unless location[:arrival].nil?
                location[:public_arrival] = TSDBExplorer::normalise_datetime(run_date + " " + location[:public_arrival]) unless location[:public_arrival].nil?

                location[:pass] = TSDBExplorer::normalise_datetime(run_date + " " + location[:pass]) unless location[:pass].nil?

                location[:departure] = TSDBExplorer::normalise_datetime(run_date + " " + location[:departure]) unless location[:departure].nil?
                location[:public_departure] = TSDBExplorer::normalise_datetime(run_date + " " + location[:public_departure]) unless location[:public_departure].nil?

                # Set the Train UUID

                location[:basic_schedule_uuid] = schedule[:basic][:uuid]

                Location.create!(location)

              end


              # Add a terminating location

              terminate_clone = schedule[:terminate].clone
              terminate_clone[:basic_schedule_uuid] = schedule[:basic][:uuid]

              terminate_clone[:arrival] = TSDBExplorer::normalise_datetime(run_date + " " + terminate_clone[:arrival])
              terminate_clone[:public_arrival] = TSDBExplorer::normalise_datetime(run_date + " " + terminate_clone[:public_arrival])

              Location.create!(terminate_clone)

            end

          else

            raise "Invalid transaction type '#{schedule[:basic][:transaction_type]}' for BS record at line #{line_number}"

          end

        end

      end

      return stats

    end


    # Process a Basic Schedule deletion record

    def CIF.delete_bs_record(bs_record, stats)

      if bs_record[:runs_to].nil?
        date_range = Array.new
        date_range << bs_record[:runs_from]
      else
        date_range = TSDBExplorer.date_range_to_list(bs_record[:runs_from], bs_record[:runs_to], bs_record[:days_run])
      end

      date_range.each do |run_date|
        schedule = BasicSchedule.find_by_run_date(run_date)
        schedule.delete
        stats[:schedule][:delete] = stats[:schedule][:delete] + 1
      end

      return stats

    end



  end


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
  