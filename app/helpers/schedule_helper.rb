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
      when "B"
        'bus_64x64.png'
      when "5"
        'bus_64x64.png'
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

end
