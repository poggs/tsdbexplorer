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

    yy = date.slice(0,2).to_i
    mm = date.slice(2,2).to_i
    dd = date.slice(4,2).to_i

    if yy >= 60 && yy <= 99
      century = 19
    else
      century = 20
    end

    return century.to_s + yy.to_s.rjust(2,"0") + "-" + mm.to_s.rjust(2,"0") + "-" + dd.to_s.rjust(2,"0")

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


  # Split a line in to fields based on the contents of field_array.  The contents
  # of each field is trimmed to remove whitespace, which may result in a field
  # being blank.  In this case, blank values are replaced with a nil value.
  #
  # The field_array is an array comprised of one or more arrays with a field name
  # and a field length, for example, [ :record_identity, 2 ].  Each field starts
  # at the end of the previous field.

  def TSDBExplorer.cif_parse_line(data, field_array)

    raise "Field hash must be an array" unless field_array.is_a? Array

    pos = 0
    result_hash = Hash.new

    field_array.each do |field|

      field_name = field[0].to_sym

      value = data.slice(pos, field[1])

      result_hash[field_name] = value == '' ? nil : value
      pos = pos + field[1]

    end

    return result_hash

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



  module CIF

    def CIF.process_cif_file(filename)

      cif_data = File.open(filename)
      puts "Processing #{filename}"


      # The first line of the CIF file must be an HD record

      header_line = cif_data.first
      header_data = TSDBExplorer.cif_parse_line(header_line, [ [ :record_identity, 2 ], [ :file_mainframe_identity, 20 ], [ :date_of_extract, 6 ], [ :time_of_extract, 4 ], [ :current_file_ref, 7 ], [ :last_file_ref, 7 ], [ :update_indicator, 1 ], [ :version, 1 ], [ :user_extract_start_date, 6 ], [ :user_extract_end_date, 6], [ :spare, 20 ] ])

      raise "Expecting an HD record at the start of #{cif_filename} - found a '#{header_data[:record_identity]}' record" unless header_data[:record_identity] == "HD"


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

      stats = { :tiploc => { :insert => 0, :amend => 0, :delete => 0 }, :association => { :insert => 0, :amend => 0, :delete => 0 } }

      cif_data.each do |record|

        next if end_of_data == 1 && record.blank?
        raise "Data found after ZZ record" if end_of_data == 1

        line_number = line_number + 1

        record_identity = record.slice(0,2)

        if record_identity == "ZZ"

          # NOTE: If there are any TIPLOCs due to be created from TI records, these should be processed now

          unless pending_trans['Tiploc'].blank?
            Tiploc.import pending_trans['Tiploc']
            pending_trans['Tiploc'] = Array.new
          end

          end_of_data == 1

        elsif record_identity == "TI"

          # TI: TIPLOC Insert

          tiploc = TSDBExplorer.cif_parse_line(record, [ [ :record_identity, 2 ], [ :tiploc_code, 7 ], [ :capitals_identification, 2 ], [ :nalco, 6 ], [ :nlc_check_character, 1 ], [ :tps_description, 26 ], [ :stanox, 5 ], [ :po_mcp_code, 4 ], [ :crs_code, 3 ], [ :description, 16 ], [ :spare, 8 ] ])

          tiploc.delete :record_identity
          tiploc.delete :po_mcp_code
          tiploc.delete :spare

          pending_trans['Tiploc'] << Tiploc.new(tiploc)

          stats[:tiploc][:insert] = stats[:tiploc][:insert] + 1

        elsif record_identity == "TD"

          # TD: TIPLOC Delete

          # NOTE: If there are any TIPLOCs due to be created from TI records, these should be processed now

          unless pending_trans['Tiploc'].blank?
            Tiploc.import pending_trans['Tiploc']
            pending_trans['Tiploc'] = Array.new
          end

          tiploc = TSDBExplorer.cif_parse_line(record, [ [ :record_identity, 2 ], [ :tiploc_code, 7 ], [ :spare, 71 ] ])

          model_object = Tiploc.find_by_tiploc_code(tiploc[:tiploc_code].strip)

          if model_object.nil?
            return { :error => "TIPLOC #{tiploc[:tiploc_code]} not found in TD record at line #{line_number}" }
          else
            model_object.delete
            stats[:tiploc][:delete] = stats[:tiploc][:delete] + 1
          end

        elsif record_identity == "AA"

          # AA: Association

          association = TSDBExplorer.cif_parse_line(record, [ [ :record_identity, 2 ], [ :transaction_type, 1 ], [ :main_train_uid, 6 ], [ :assoc_train_uid, 6 ], [ :association_start_date, 6 ], [ :association_end_date, 6 ], [ :association_days, 7 ], [ :category, 2 ], [ :date_indicator, 1 ], [ :location, 7 ], [ :base_location_suffix, 1 ], [ :assoc_location_suffix, 1 ], [ :diagram_type, 1 ], [ :assoc_type, 1 ], [ :spare, 31 ], [ :stp_indicator, 1 ] ])

          association[:association_start_date] = TSDBExplorer.yymmdd_to_date(association[:association_start_date])
          association[:association_end_date] = TSDBExplorer.yymmdd_to_date(association[:association_end_date])

          if association[:transaction_type] == "N"

            # New record

            association.delete :record_identity
            association.delete :transaction_type
            association.delete :spare


            # Expand the date range

            raise if association[:association_end_date] == "999999"

            date_range = TSDBExplorer.date_range_to_list(association[:association_start_date], association[:association_end_date], association[:association_days])
            association.delete :association_start_date
            association.delete :association_end_date
            association.delete :association_days

            date_range.each do |assoc_date|

              association[:date] = assoc_date
              pending_trans['Association'] << Association.new(association)
              stats[:association][:insert] = stats[:association][:insert] + 1

            end

            Association.import pending_trans['Association']

          elsif association[:transaction_type] == "D"

            # Delete record

            model_object = Association.find(:first, :conditions => { :main_train_uid => association[:main_train_uid], :assoc_train_uid => association[:assoc_train_uid], :date => association[:association_start_date] })
            model_object.delete

            stats[:association][:delete] = stats[:association][:delete] + 1

          elsif association[:transaction_type] == "R"

            raise "Transaction type 'R' for AA records is not yet supported"

          else

            raise "Invalid transaction type '#{association[:transaction_type]}' for AA record at line #{line_number}"

          end

        else
          return { :error => "Unsupported record type #{record_identity} found at line #{line_number}" }
        end

      end

      return stats

    end

  end

end
  