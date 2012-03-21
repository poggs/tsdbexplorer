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

require 'tsdbexplorer/tdnet.rb'
require 'tsdbexplorer/cif.rb'
require 'tsdbexplorer/geography.rb'
require 'tsdbexplorer/realtime.rb'
require 'tsdbexplorer/rsp.rb'

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

    if date == "999999"
      nil
    else 
      century = date[0..1].to_i >= 60 && date[0..1].to_i <= 99 ? "19" : "20"
      century + date[0..1] + "-" + date[2..3] + "-" + date[4..5]           
    end

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


  # Convert a date/time in YYYYMMDDHHMMSS format to a Time object

  def TSDBExplorer.yyyymmddhhmmss_to_time(datetime)

    parsed_time = nil

    unless datetime == "00000000000000"
      begin
        parsed_time = Time.parse(datetime)
      rescue
        parsed_time = nil
      end
    end

    return parsed_time

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


  # Sort a list of trains on arrival, pass and departure times

  def TSDBExplorer.train_sort(a, b)

    if !a[:arrival].nil? && !a[:departure].nil?
      cmp_a = :departure  # CALL
    elsif !a[:arrival].nil? && a[:departure].nil?
      cmp_a = :arrival    # TERM
    elsif a[:arrival].nil? && !a[:departure].nil?
      cmp_a = :departure  # ORIG
    else
      cmp_a = :pass
    end

    if !b[:arrival].nil? && !b[:departure].nil?
      cmp_b = :departure  # CALL
    elsif !b[:arrival].nil? && b[:departure].nil?
      cmp_b = :arrival    # TERM
    elsif b[:arrival].nil? && !b[:departure].nil?
      cmp_b = :departure  # ORIG
    else
      cmp_b = :pass
    end 

    return a[cmp_a] <=> b[cmp_b]

  end


  # Convert a TRUST activation schedule source in to text

  def TSDBExplorer.schedule_source_to_text(s)

    if s == "C"
      "CIF"
    elsif s == "V"
      "VSTP"
    else
      nil
    end

  end


  # Convert a TRUST activation schedule type in to text

  def TSDBExplorer.schedule_type_to_text(t)

    if t == "P"
      "WTT"
    elsif t == "N"
      "STP"
    elsif t == "O"
      "VAR"
    elsif t == "C"
      "CAN"
    end

  end


  # Converts a time in the format HHMM(H) in to the number of seconds since midnight

  def TSDBExplorer.time_to_seconds(t)

    hours = t[0..1].to_i
    minutes = t[2..3].to_i
    seconds = t[4]

    return (hours * 3600) + (minutes * 60) + (seconds == "H" ? 30 : 0)

  end

end
