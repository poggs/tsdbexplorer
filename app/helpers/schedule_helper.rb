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

module ScheduleHelper

  include ApplicationHelper

  # Return icons for the type of catering available on a train

  def catering_icon(code)

    data = nil

    unless code.nil? || code.blank?

      icons = Array.new

      code.split(//).each do |c|
        icon = case code
          when "C"  # Buffet service
            [ 'cake.png', 'Buffet' ]
          when "F"  # Restaurant for First Class passengers
            [ 'cutlery.png', 'Restaurant for 1st Class passengers' ]
          when "H"  # Service of hot food available
            [ 'hamburger.png', 'Hot food service' ]
          when "M"  # Meal for First Class passengers
            [ 'cutlery.png', 'Meal for 1st Class passengers' ]
          when "P"  # Wheelchair only reservations
            nil # TODO: Provide wheelchair icon
          when "R"  # Restaurant
            [ 'cutlery.png', 'Restaurant' ]
          when "T"  # Trolley service
            [ 'cake.png', 'Trolley' ]
          else
            nil
        end
        icons << icon unless icon.nil?
      end

      html = icons.collect { |icon,description| "<li>" + image_tag('catering/' + icon, :alt => description) + " " + description + "</li>" }

      data = "<ul>\n" + html.join("\n") + "</ul>\n" unless icons.blank?

    end

    return data

  end


  # Return an icon for a transport mode

  def mode_icon_for(code)

    icon = nil

    image_file = case code
      when "P"
        'train_64x64.png'
      when "F"
        'train_64x64.png'
      when "T"
        'train_64x64.png'
      when "1"
        'train_64x64.png'
      when "2"
        'train_64x64.png'
      when "3"
        'train_64x64.png'
      when "B"
        'bus_64x64.png'
      when "5"
        'bus_64x64.png'
      when "S"
        'ship_64x64.png'
      when "4"
        'ship_64x64.png'
      else
        nil
    end

    icon = image_tag(image_file) unless image_file.nil?

    return icon

  end


  # Decode a train category in to text

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
      "BR" => "Bus - Replacement due to engineering work",
      "BS" => "Bus - WTT Service",
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

    return "#{decoded_category}"

  end


  # Return the days a schedule is valid in textual format

  def runs_on_days(schedule)

    text = nil

    if schedule[:runs_mo] && schedule[:runs_tu] && schedule[:runs_we] && schedule[:runs_th] && schedule[:runs_fr] && schedule[:runs_sa] && schedule[:runs_su]
      text = "every day"
    elsif schedule[:runs_mo] && schedule[:runs_tu] && schedule[:runs_we] && schedule[:runs_th] && schedule[:runs_fr] && !schedule[:runs_sa] && !schedule[:runs_su]
      text = "every weekday"
    elsif !schedule[:runs_mo] && !schedule[:runs_tu] && !schedule[:runs_we] && !schedule[:runs_th] && !schedule[:runs_fr] && schedule[:runs_sa] && schedule[:runs_su]
      text = "weekends"
    else

      days = Array.new
      mapping = { :runs_mo => 'Monday', :runs_tu => 'Tuesday', :runs_we => 'Wednesday', :runs_th => 'Thursday', :runs_fr => 'Friday', :runs_sa => 'Saturday', :runs_su => 'Sunday' }
      mapping.each do |k,v|
        days.push v if schedule[k] == true
      end

      if days.count == 1
        text = days.first + " only"
      elsif days.count == 2
        text = days.join(" and ")
      else
        text = days[0..(days.count-2)].join(", ") + " and " + days.last
      end

    end

    return text

  end


  def run_details(schedule)

    if schedule.runs_from == schedule.runs_to
      "#{date_range_or_date(schedule.runs_from, schedule.runs_to)} only"
    else
      "#{runs_on_days(schedule)} #{date_range_or_date(schedule.runs_from, schedule.runs_to)}"
    end

  end


  # Return the scheduled, expected or actual time for the arrival, passing or departure time

  def format_time(location, type, public_or_wtt)

    html_class = nil
    value = nil

    if ['arrival', 'pass', 'departure'].include? type

      scheduled = nil

      if public_or_wtt == :public
        scheduled = location.send('public_' + type)
      end

      scheduled = location.send(type) if scheduled.nil?

      expected = location.send("expected_" + type)
      actual = location.send("actual_" + type)

      if !actual.nil?
        if (actual - scheduled) >= 180
          html_class = "actual late"
        elsif (actual - scheduled) >= -180 && (actual - scheduled) < 180
          html_class = "actual ontime"
        else
          html_class = "actual early"
        end
        value = actual
      elsif !expected.nil?
        if (expected - scheduled) >= 180
          html_class = "expected late"
        elsif (expected - scheduled) >= -180 && (expected - scheduled) < 180
          html_class = "expected ontime"
        else
          html_class = "expected early"
        end
        value = expected
      else !scheduled.nil?
        value = scheduled
        html_class = "scheduled"
      end

      value = time_only(value)

    else

      html_class = "error"
      value = "ERROR"

    end

    return content_tag(:span, value, :class => html_class)

  end


  # Decode a set of operating characteristics in to text

  def decode_operating_characteristics(oper_char)

    operating_characteristics = Array.new

    unless oper_char.nil? || oper_char.blank?

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
          operating_characteristics.push "#{operating_characteristics_hash[characteristic]}"
        else
          operating_characteristics.push "Unknown (#{characteristic})"
        end
      end

    end

    return operating_characteristics.length == 0 ? nil : operating_characteristics.join(", ")

  end


  # Calculate the variation between an arrival and departure time

  def calculate_variation(loc)

    a_or_d = nil
    e_or_l = nil

    variation = nil

    if loc.cancelled?
      variation = content_tag(:span, "Cancelled", :class => 'label important')
    else

      if !loc.actual_departure.nil?

        departure = loc.public_departure.nil? ? loc.departure : loc.public_departure

        varn = departure - loc.actual_departure

        if varn < -30
          e_or_l = 'late'
        elsif varn > 30
          e_or_l = 'early'
        end

        variation = "Departed " + (e_or_l.nil? ? "on-time" : "#{distance_of_time_in_words(departure, loc.actual_departure, true)} #{e_or_l}")

      elsif !loc.actual_arrival.nil?

        arrival = loc.public_arrival.nil? ? loc.arrival : loc.public_arrival

        varn = arrival - loc.actual_arrival

        if varn < -30
          e_or_l = 'late'
        elsif varn > 30
          e_or_l = 'early'
        end

        variation = "Arrived " + (e_or_l.nil? ? "on-time" : "#{distance_of_time_in_words(arrival, loc.actual_arrival, true)} #{e_or_l}")

      elsif !loc.pass.nil? && !loc.actual_pass.nil?

        varn = loc.pass - loc.actual_pass

        if varn < 0
          e_or_l = 'late'
        elsif varn > 0
          e_or_l = 'early'
        end

        variation = "Passed " + (e_or_l.nil? ? "on-time" : "#{distance_of_time_in_words(loc.pass, loc.actual_pass, true)} #{e_or_l}")

      else

        variation = "No report"

      end

    end

    return variation

  end


  # Given a BasicSchedule, returns the schedule type as either an abbreviation ('A') or full-text ('F')

  def decode_stp_indicator(schedule, type)

    mapping = { 'C' => { :A => 'CAN', :F => 'Cancelled' }, 'N' => { :A => 'STP', :F => 'Short-term planned' }, 'O' => { :A => 'VAR', :F => 'Short-term planned alteration' }, 'P' => { :A => 'WTT', :F => 'Permanent' } }

    if mapping.has_key? schedule.stp_indicator
      mapping[schedule.stp_indicator][type]
    else
      nil
    end

  end


  # Return a list of activities

  def format_activities(loc)

    activity_hash = {
      'D' => 'Stops to set down passengers only',
      'L' => 'Stops to change locomotive',
      'N' => 'Unadvertised stop',
      'R' => 'Stops when required',
      'OP' => 'Stops for operational reasons',
      'RM' => 'Reversing movement',
      'RR' => 'Stops for locomotive to run round train',
      'S' => 'Stops for railway personnel only',
      'TW' => 'Stops for tablet, staff or token',
      'U' => 'Stops to pick up passengers only',
      '-D' => 'Stops to detach vehicles',
      '-U' => 'Stops to attach vehicles'
    }

    activities = Array.new

    activity_hash.collect { |k,v| activities.push(content_tag 'a', k, { :href => '#', :rel => 'tooltip', :title => v }) if loc.send('activity_' + k.downcase.gsub('-', 'minus')) == true }

    return activities.collect { |a| "<span class=\"label activity\">" + a + "</span>" }.join("&nbsp;")

  end


  # Show a location name, or "Starts here"/"Terminates here" if appropriate

  def show_location_name(loc, type)

    if type == :from && loc.activity_tb == true
      text = "Starts here"
      tiploc = loc.tiploc_code
    elsif type == :to && loc.activity_tf == true
      text = "Terminates here"
      tiploc = loc.tiploc_code
    else
      if type == :from
        text = "<strong>" + decode_tiploc(loc.basic_schedule.origin) + "</strong>"
        tiploc = loc.basic_schedule.origin.tiploc_code
      else
        text = "<strong>" + decode_tiploc(loc.basic_schedule.terminate) + "</strong>"
        tiploc = loc.basic_schedule.terminate.tiploc_code
      end
    end

    if session['mode'] == 'advanced'
      location_code = loc.tiploc_code
    else
      crs_code = $REDIS.hget('TIPLOC:' + tiploc, 'crs_code')
      location_code = crs_code unless crs_code.nil?
    end

    return text

  end


  # Format allowances in to text

  def format_allowances(l)

    a = Array.new

    a.push("[#{tidy_wtt_time(l.engineering_allowance)}]") unless l.engineering_allowance.nil?
    a.push("(#{tidy_wtt_time(l.pathing_allowance)})") unless l.pathing_allowance.nil?
    a.push("<#{tidy_wtt_time(l.performance_allowance)}>") unless l.performance_allowance.nil?

    a.join(" ") unless a.blank?

  end

end
