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
    date_obj.sec == 30 ? date_obj.strftime('%H%M')+"H" : date_obj.strftime('%H%M') if date_obj.is_a? Time
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
      " " => "1st and Standard seats",
      "B" => "1st and Standard seats",
      "S" => "Standard Class only"
    }
    
    if train_class_hash.has_key? train_class
      decoded_class = train_class_hash[train_class]
    else
      decoded_class = "Unknown"
    end
    
    return "#{train_class}: #{decoded_class}"
  
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

end
