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

    if act.nil?
      return time_only(sch)
    else

      varn = 0

      if sch.nil?
        delay = ""
      else
        varn = (act - sch) / 60

        if varn > 5
          delay = "late"
        elsif varn < 0
          delay = "early"
        else
          delay = "ontime"
        end

      end

      return "<div class=\"#{delay}\">#{time_only(act)}</div>"

    end

  end

  def decode_toc(toc)

    toc_hash = {
      "LM" => "London Midland",
      "LO" => "London Overground",
      "VT" => "Virgin Trains",
      "LE" => "National Express East Anglia"
    }

    if toc_hash.has_key? toc
      return toc_hash[toc]
    else
      return toc
    end

  end

  def decode_train_category(category)
  
    category_hash = {

      "OL" => "London Underground/Metro Service",
      "OU" => "Unadvertised Ordinary Passenger",
      "OO" => "Ordinary Passenger",
      "OS" => "Staff Train",
      "OW" => "Mixed",
      "XC" => "Channel Tunnel",
      "XD" => "Sleeper (Europe Night Services)",
      "XI" => "International",
      "XR" => "Motorail",
      "XU" => "Unadvertised Express",
      "XX" => "Express Passenger",
      "XZ" => "Sleeper (Domestic)",
      "BR" => "Bus – Replacement due to engineering work",
      "BS" => "Bus – WTT Service",
      "EE" => "Empty Coaching Stock (ECS)",
      "EL" => "ECS, London Underground/Metro Service.",
      "ES" => "ECS & Staff",
      "JJ" => "Postal",
      "PM" => "Post Office Controlled Parcels",
      "PP" => "Parcels",
      "PV" => "Empty NPCCS",
      "DD" => "Departmental",
      "DH" => "Civil Engineer",
      "DI" => "Mechanical & Electrical Engineer",
      "DQ" => "Stores",
      "DT" => "Test",
      "DY" => "Signal & Telecommunications Engineer",
      "ZB" => "Locomotive & Brake Van",
      "ZZ" => "Light Locomotive",
      "J2" => "RfD Automotive (Components)",
      "H2" => "RfD Automotive (Vehicles)",
      "J3" => "RfD Edible Products (UK Contracts)",
      "J4" => "RfD Industrial Minerals (UK Contracts)",
      "J5" => "RfD Chemicals (UK Contracts)",
      "J6" => "RfD Building Materials (UK Contracts)",
      "J8" => "RfD General Merchandise (UK Contracts)",
      "H8" => "RfD European",
      "J9" => "RfD Freightliner (Contracts)",
      "H9" => "RfD Freightliner (Other)",
      "A0" => "Coal (Distributive)",
      "E0" => "Coal (Electricity) MGR ",
      "B0" => "Coal (Other) and Nuclear",
      "B1" => "Metals",
      "B4" => "Aggregates",
      "B5" => "Domestic and Industrial Waste",
      "B6" => "Building Materials (TLF)",
      "B7" => "Petroleum Products",
      "H0" => "RfD European Channel Tunnel (Mixed Business)",
      "H1" => "RfD European Channel Tunnel Intermodal",
      "H3" => "RfD European Channel Tunnel Automotive",
      "H4" => "RfD European Channel Tunnel Contract Services",
      "H5" => "RfD European Channel Tunnel Haulmark",
      "H6" => "RfD European Channel Tunnel Joint Venture"

    }

    if category_hash.has_key? category
      decoded_category = category_hash[category]
    else
      decoded_category = "Unknown"
    end
    
    return "#{category}: #{decoded_category}"
    
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


  def decode_reservations(reservations)

    reservation_hash = {
      "A" => "Reservations compulsory",
      "E" => "Reservations essential for bicycles",
      "R" => "Reservations recommended",
      "S" => "Reservations possible"
    }

    if reservations == " " || reservations.nil?
      decoded_reservations = "Not available"
    elsif reservation_hash.has_key? reservations
      decoded_reservations = "#{reservations}: #{reservation_hash[reservations]}"
    else
      decoded_reservations = "#{reservations}: Unknown"
    end

    return decoded_reservations

  end


  def decode_catering(catering)

    catering_facilities = Array.new

    if catering.blank?

      catering_facilities.push 'None'

    else

      catering_hash = {
        "C" => "Buffet Service",
        "F" => "Restaurant for First Class passengers",
        "H" => "Hot Food service",
        "M" => "Inclusive meal for First Class passengers",
        "P" => "Wheelchair-only reservations",
        "R" => "Restaurant",
        "T" => "Trolley Service"
      }

      catering.split('').each do |catering_code|
        if catering_hash.has_key? catering_code
          catering_facilities.push catering_hash[catering_code]
        else
          catering_facilities.push "Unknown facility #{catering_code}"
        end
      end

    end

    return catering_facilities.join(", ")

  end

  def decode_operating_characteristics(oper_char)

    operating_characteristics = Array.new

    if oper_char.nil? || oper_char.blank?

      return "None"

    end

    operating_characteristics_hash = {
      "B" => "Vacuum Braked",
      "C" => "Timed at 100mph",
      "D" => "DOO",
      "E" => "Mark 4 coaches",
      "G" => "Guard required",
      "M" => "Timed at 110mph",
      "P" => "Push/Pull train",
      "Q" => "Runs as required",
      "R" => "Air conditioned with PA system",
      "S" => "Steam heated",
      "Y" => "Runs to terminals/yard as required",
      "Z" => "Not to be diverted from booked route"
    }

    oper_char.split('').each do |characteristic|
      if operating_characteristics_hash.has_key? characteristic
        operating_characteristics.push "#{characteristic}: #{operating_characteristics_hash[characteristic]}"
      else
        operating_characteristics.push "#{characteristic}: Unknown"
      end
    end

    return operating_characteristics.join(", ")

  end

  def decode_tiploc(obj)

    decoded_tiploc = nil

    if obj.is_a? Tiploc
      decoded_tiploc = tidy_text((obj.tps_description.blank? || obj.tps_description.nil?) ? obj.tiploc_code : obj.tps_description)
    elsif obj.is_a? Location
      decoded_tiploc = obj.tiploc.nil? ? obj.tiploc_code : obj.tiploc.tps_description
    elsif obj.is_a? DailyScheduleLocation
      decoded_tiploc = obj.tiploc.nil? ? obj.tiploc_code : obj.tiploc.tps_description
    end

    return decoded_tiploc

  end


  # Replace railway jargon and abbreviations in text with more accessible
  # words, e.g.  "JN." becomes "Junction", "SDGS" becomes "Sidings".

  def tidy_text(tiploc)

    words = Array.new

    words = tiploc.split(' ') unless tiploc.nil?

    abbreviations = { 'C.S.D' => 'Carriage Sidings',
                      'ELL' => '(ELL)',
                      'H.S.T.D.' => 'HST Depot',
                      'RECP' => 'Reception',
                      'DC' => 'D.C.',
                      'D.C.' => 'D.C.',
                      'DN' => 'Down',
                      'BDG' => 'Bridge',
                      'HL' => 'High Level',
                      'H.L.' => 'High Level',
                      'JCN' => 'Junction',
                      'JN.' => 'Junction',
                      'JN' => 'Junction',
                      'J' => 'Junction',
                      'INTL' => 'International',
                      'D.M.U.D.' => 'DMUD',
                      'E.M.U.D.' => 'EMUD',
                      'RD' => 'Road',
                      'RD.' => 'Road',
                      'N' => 'North',
                      'N.' => 'North',
                      'NTH' => 'North',
                      'S' => 'South',
                      'S.' => 'South',
                      'STH' => 'South',
                      'STH.' => 'South',
                      'SDG' => 'Siding',
                      'STH' => 'South',
                      'ST' => 'St.',
                      'STN' => 'Station',
                      'T.M.D' => 'TMD',
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

        brackets = part.match(/^\((.+)\)/)

        if brackets.nil?
          new_words.push part.capitalize
        else
          new_words.push "(" + brackets[1].capitalize + ")"
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

end
