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

module ApplicationHelper

  def time_only(date_obj)
    date_obj.sec == 30 ? date_obj.localtime.strftime('%H%M')+"H" : date_obj.localtime.strftime('%H%M') if date_obj.is_a? Time
  end

  def platform_or_actual(sch, act)

    if act.nil?
      return sch
    else
      return "<strong>#{act}</strong>"
    end

  end

  def schedule_or_actual(sch, act)

    return time_only(sch) if act.nil?

    varn = 0

    if sch.nil?
      delay = ""
    else
      varn = (act - sch) / 60

      if varn >= 5
        delay = "late"
      elsif varn >= -3 && varn < 5
        delay = "ontime"
      elsif varn < -3
        delay = "early"
      end

    end

    return "<div class=\"#{delay}\">#{time_only(act)}</div>"

  end

  def decode_toc(toc)

    toc_hash = {
      "AW" => "ARRIVA Trains Wales",
      "CC" => "c2c",
      "CH" => "Chiltern Railways",
      "EM" => "East Midlands Trains",
      "ES" => "Eurostar",
      "FC" => "First Capital Connect",
      "GC" => "Grand Central",
      "GR" => "East Coast",
      "GW" => "First Great Western",
      "GX" => "Gatwick Express",
      "HC" => "Heathrow Connect",
      "HT" => "Hull Trains",
      "HX" => "Heathrow Express",
      "IL" => "Island Line",
      "LE" => "Greater Anglia",
      "LM" => "London Midland",
      "LO" => "London Overground",
      "LT" => "London Underground",
      "ME" => "Merseyrail",
      "NT" => "Northern",
      "NY" => "North Yorkshire Moors Railway",
      "PT" => "Europorte 2",
      "SE" => "Southeastern",
      "SN" => "Southern",
      "SR" => "Scotrail",
      "SW" => "South West Trains",
      "TP" => "First TransPennine Express",
      "TW" => "Tyne and Wear Metro",
      "VT" => "Virgin Trains",
      "WR" => "West Coast Railway Co.",
      "WS" => "Wrexham & Shropshire",
      "XC" => "CrossCountry"
    }

    if toc_hash.has_key? toc
      return toc_hash[toc]
    else
      return nil
    end

  end

  def display_operator(toc)

    toc_name = decode_toc(toc)

    if toc_name.nil?
      "No operator information available"
    else
      "Operated by #{toc_name}"
    end

  end

  def decode_train_class(train_class)

    train_class_hash = {
      nil => "Unknown",
      "" => "Unknown",
      " " => "1st and Standard seats",
      "B" => "1st and Standard seats",
      "S" => "Standard Class only"
    }

    if train_class_hash.has_key? train_class
      decoded_class = "#{train_class_hash[train_class]}"
    else
      decoded_class = "#{train_class}: Unknown"
    end

    return decoded_class

  end


  def decode_train_status(train_status)

    train_status_hash = {
      "P" => "Passenger/Parcels",
      "F" => "Freight",
      "T" => "Trip",
      "B" => "Bus",
      "S" => "Ship",
      "1" => "Passenger/Parcels (STP)",
      "2" => "Freight (STP)",
      "3" => "Trip (STP)",
      "4" => "Ship (STP)",
      "5" => "Bus (STP)"
    }

    if train_status_hash.has_key? train_status
      decoded_train_status = train_status_hash[train_status]
    else
      decoded_train_status = "Unknown"
    end
    
    return "#{train_status}: #{decoded_train_status}"

  end


  # Decode a TIPLOC in to text, using the in-memory database where possible

  def decode_tiploc(obj)

    decoded_tiploc = nil

    if obj.is_a? Tiploc
      decoded_tiploc = tidy_text((obj.tps_description.blank? || obj.tps_description.nil?) ? obj.tiploc_code : obj.tps_description)
    elsif (obj.is_a? Location) || (obj.is_a? DailyScheduleLocation)
      decoded_tiploc = $REDIS.hget('TIPLOC:' + obj.tiploc_code, 'description')
      if decoded_tiploc.nil?
        logger.warn "ApplicationHelper::decode_tiploc() failed to find #{obj.tiploc_code}"
        decoded_tiploc = obj.tiploc.nil? ? obj.tiploc_code : obj.tiploc.tps_description
      end
    end

    return decoded_tiploc

  end


  # Replace railway jargon and abbreviations in text with more accessible
  # words, e.g.  "JN." becomes "Junction", "SDGS" becomes "Sidings".

  def tidy_text(tiploc)

    words = Array.new

    words = tiploc.split(' ') unless tiploc.nil?

    abbreviations = { 'CARR.' => 'Carriage',
                      'C.S.D' => 'Carriage Servicing Depot',
                      'C.S.D.' => 'Carriage Servicing Depot',
                      'C.S.' => 'Carriage Sidings',
                      'ELL' => '(ELL)',
                      'H.S.T.D.' => 'HST Depot',
                      'RECP' => 'Reception',
                      'DC' => '(DC)',
                      'D.C.' => '(DC)',
                      'DN' => 'Down',
                      'DBS' => 'DBS',
                      'DRS' => '(DRS)',
                      'ELL' => '(East London Line)',
                      'BDG' => 'Bridge',
                      'HL' => 'High Level',
                      'H.L.' => '(High Level)',
                      'H.S.' => 'Holding Siding',
                      'L.L.' => '(Low Level)',
                      'LN' => 'Lane',
                      'JCN' => 'Junction',
                      'JN.' => 'Junction',
                      'JN' => 'Junction',
                      'J' => 'Junction',
                      'INTL' => 'International',
                      'LC' => 'Level Crossing',
                      'LUL' => '(London Underground)',
                      'L.N.W.' => 'London North Western',
                      'D.M.U.D.' => 'DMUD',
                      'E.M.U.D.' => 'EMUD',
                      'R.E.S.' => "(RES)",
                      'RD' => 'Road',
                      'RD.' => 'Road',
                      'R.T.C.' => 'RTC',
                      'N' => 'North',
                      'N.' => 'North',
                      'NTH' => 'North',
                      'S' => 'South',
                      'S.' => 'South',
                      'SIG' => 'Signal',
                      'STH' => 'South',
                      'STH.' => 'South',
                      'SDG' => 'Siding',
                      'STH' => 'South',
                      'ST' => 'St.',
                      'STN' => 'Station',
                      'T.C.' => 'TC',
                      'T.M.D' => 'TMD',
                      'T&R.S.M.D' => 'T&RSMD',
                      'T.&R.S.M.D.' => 'T&RSMD',
                      'U.R.S.' => 'Up Reception Siding',
                      'W' => 'West',
                      'E' => 'East',
                      'S.B.' => 'Signal Box',
                      'LONDN' => 'London',
                      'SDGS' => 'Sidings',
                      'L.U.L.' => '(LUL)' }

    new_words = Array.new

    words.each do |part|

      # Check if this word is in the abbreviations hash, and if so, use the long version of the abbreviation

      if abbreviations.has_key? part

        new_words.push abbreviations[part]

      else

        # Some locations are in brackets - these require special treatment

        brackets = part.match(/\((.+)/)

        if brackets.nil?
          new_words.push part.capitalize
        else
          new_words.push "(" + brackets[1].capitalize
        end

      end

    end

    return new_words.join(' ')

  end


  # Translate a TRUST cancellation code to text.  The codes here are taken
  # from the Delay Attribution Guide, Appendix A

  def da_to_text(da_code)

    map = { "IA" => "a signal failure",
            "IB" => "a points failure",
            "IC" => "a track circuit failure",
            "ID" => "a level crossing failure",
            "IE" => "a power failure",
            "IF" => "a failure of part of the signalling system",
            "IG" => "a signalling block failure" ,
            "II" => "a power cable fault",
            "IJ" => "a trackside safety equipment failure",
            "IK" => "a lineside telephone failure",
            "IL" => "failure of token-based signalling equipment",
            "IM" => "bailse failure",
            "IN" => "a fault with trackside train verification equipment",
            "IO" => "a suspected fault with trackside train verification equipment",
            "IP" => "a points failure due to faulty point heaters",
            "IQ" => "a damaged trackside sign",
            "IR" => "a rail flaw",
            "IS" => "a track defect",
            "IT" => "a reported bump",
            "IU" => "an engineering train affecting maintenance work",
            "IV" => "a landslide or sea defence failure",
            "IW" => "the effects of cold weather on trackside infrastructure",
            "IY" => "a mishap",
            "IZ" => "an infrastructure problem",
            "I0" => "a telecommunications failure",
            "I1" => "an overhead line or third-rail defect",
            "I2" => "a power supply tripping",
            "I3" => "an obstruction on the overhead power lines",
            "I4" => "a power supply failure or reduction",
            "I5" => "overrunning planned engineering works",
            "I6" => "track patrolling",
            "I7" => "a late or failed engineer's train within a possession",
            "I8" => "a train striking an animal",
            "I9" => "a fire on the railway",
            "MA" => "a problem with the train's brakes",
            "MB" => "a problem with the train's motors",
            "MC" => "a problem with the train's motors",
            "MD" => "a problem with the train's motors",
            "ME" => "a problem with the train's engine",
            "MF" => "a problem with an international train",
            "MG" => "a problem with the brakes on a coach",
            "MH" => "a problem with the doors on a coach",
            "MI" => "a problem with one of the coaches",
            "MJ" => "a problem with a parcels coach",
            "MK" => "a problem with the train's driving cab",
            "ML" => "a problem with a freight vehicle",
            "MM" => "a problem with the train's traction",
            "MN" => "a problem with the train's brakes",
            "MO" => "the train arriving late from the depot",
            "MP" => "slippery rails",
            "MQ" => "a problem with the locomotive",
            "MR" => "an alert from a trackside safety system",
            "MS" => "the train being swapped for another",
            "MT" => "a problem with the train's safety system",
            "MU" => "a problem in the depot",
            "MV" => "a problem with an engineering train",
            "MW" => "poor weather conditions",
            "MX" => "a problem with the train's brakes",
            "MY" => "an incident",
            "MZ" => "a problem",
            "M1" => "a fault with the train's pantograph",
            "M2" => "a fault with the train's pantograph",
            "M3" => "a problem with a diesel locomotive",
            "M4" => "a problem with the train's brakes",
            "M5" => "a problem with the train's doors",
            "M6" => "a problem with the train",
            "M7" => "a problem with the train's doors",
            "M8" => "a problem with the train",
            "M9" => "a problem which is being investigated",
            "M0" => "a problem with the train's safety system",
            "TA" => "a crew or train diagram error",
            "TB" => "a request from the train operator",
            "TC" => "the train crew being used to operate another train",
            "TD" => "the train being used for another service",
            "TE" => "an injured passenger",
            "TF" => "a problem with seat reservations",
            "TG" => "a problem with the driver",
            "TH" => "a problem with the conductor",
            "TI" => "a problem with train crew rostering",
            "TJ" => "a problem with the train's headlamp or tail lamp",
            "TK" => "a problem with catering staff",
            "TL" => "a door not properly closed",
            "TM" => "awaiting a connecting service",
            "TN" => "the train arriving late from the continent",
            "TO" => "a problem with the train operating company",
            "TP" => "a special stop order",
            "TR" => "the instructions of the operating company",
            "TS" => "a delay due to a train safety system",
            "TT" => "seasonal operating difficulties",
            "TU" => "a problem under investigation",
            "TW" => "the driver adhering to professional driving standards",
            "TX" => "delays incurred outside the railway",
            "TY" => "an accident",
            "TZ" => "an unknown problem",
            "T1" => "a delay to the driver-only operated train at an unstaffed station",
            "T2" => "a delay to the train at an unstaffed station",
            "T3" => "awaiting a connection from a non-rail service",
            "T4" => "loading supplies",
            "VA" => "passenger disorder",
            "VB" => "vandalism or theft",
            "VC" => "an accident",
            "VD" => "a passenger taken ill on the train",
            "VE" => "a revenue protection problem",
            "VF" => "a fire caused by vandalism",
            "VG" => "police searching the train",
            "VH" => "the passenger alarm being operated on the train",
            "VI" => "a security alert",
            "VR" => "the driver adhering to professional driving standards during severe weather",
            "VW" => "severe weather",
            "VX" => "a problem on the London Underground network",
            "VZ" => "a problem which is the responsibility of the train operator",
            "V8" => "a bird strike"
             }

    return (map.has_key? da_code) ? map[da_code] : "delay causation code #{da_code}"

  end

  # Given two dates, returns 'On START' if the dates are equal, otherwise shows 'Between START and END'

  def date_range_or_date(range_start, range_end)

    if range_start == range_end
      "on #{range_end}"
    else
      "from #{range_start} to #{range_end}"
    end

  end


  # Given two dates, display 'from XXXX to YYYY on DATE' if the days are identical, otherwise display 'from XXXX on DATE1 to YYYY on DATE2' if the dates are not identical

  def date_range(date1, date2)

    text = nil

    if date1.to_date == date2.to_date
      text = "between #{date1.strftime('%H%M')} and #{date2.strftime('%H%M')} on #{date1.strftime('%A %d %B %Y')}"
    else
      text = "between #{date1.strftime('%H%M')} on #{date1.strftime('%A %d %B %Y')} and #{date2.strftime('%H%M')} on #{date2.strftime('%A %d %B %Y')}"
    end

    return text

  end


  # Formats a WTT or allowance time in to either HHMM, or HHMM with a half HTML entity appended

  def tidy_wtt_time(t)

    if t.blank?

      ""

    elsif t.length == 1 || t.length == 2

      # Allowance

      if t[0] == "H"
        "&frac12;"
      elsif t[1] == "H"
        t[0] + "&frac12;"
      else
        t
      end

    elsif t.length >= 4

      # Time

      if t[4] == " " || t[4].nil?
        t[0..3]
      else
        t[0..3] + "&frac12;"
      end

    end

  end


  # Formats the platform and line in to text

  def format_platform_and_line(loc)

    if loc.platform && loc.line
      "Plat #{loc.platform}, #{loc.line}"
    elsif loc.platform
      "Plat #{loc.platform}"
    elsif loc.line
      "#{loc.line}"
    end

  end


  # Display

  def status_data_for(status)

    if status.status == :ok
      icon = 'icon-ok'
    elsif status.status == :error
      icon = 'icon-remove'
    else
      icon = 'icon-question-sign'
    end

    "<i class=#{icon}></i>&nbsp;<em>#{status.message}</em>"

  end

  def boolean_to_image(status)

    if status == true
      icon = 'icon-ok'
    elsif status == false
      icon = 'icon-remove'
    else
      icon = 'icon-question-sign'
    end

    "<i class=#{icon}></i>"

  end


  # Time formatting

  def format_location_time(location, type)

    if [:arrival, :departure, :pass].include? type

      wtt_time = location.send(type.to_s).to_s
      gbtt_time = location.send('public_' + type.to_s).to_s unless type == :pass

      if wtt_time && type == :pass
        return '<span class="wtt"><em>' + tidy_wtt_time(wtt_time) + '</em></span>'
      elsif gbtt_time.blank?
        return '<span class="wtt">' + tidy_wtt_time(wtt_time) + '</span>'
      else
        return '<span class="wtt">' + tidy_wtt_time(wtt_time) + '</span> (<span class="gbtt">' + gbtt_time + '</span>)'
      end

    end

  end


  # Runs-as-required flag handling

  def runs_as_required_flags_for(sch)

    if sch.oper_q == true
      "(Q)"
    elsif sch.oper_y == true
      "(Y)"
    else
      nil
    end

  end


  # Icons

  def tick_icon
    tag 'i', :class => 'icon-ok'
  end

  def cross_icon
    tag 'i', :class => 'icon-remove'
  end


end
