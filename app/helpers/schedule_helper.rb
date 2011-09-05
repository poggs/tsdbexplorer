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

    return "<ul>\n" + html.join("\n") + "</ul>\n"

  end


  # Return an icon for a transport mode

  def mode_icon_for(code)

    icon = nil

    image_file = case code
      when "P"
        'train_64x64.png'
      when "B"
        'bus_64x64.png'
      else
        nil
    end

    icon = image_tag(image_file) unless image_file.nil?

    return icon

  end

end
