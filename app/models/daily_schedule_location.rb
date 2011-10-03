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

class DailyScheduleLocation < ActiveRecord::Base

  belongs_to :daily_schedule, :primary_key => :uuid, :foreign_key => :daily_schedule_uuid
  has_one :tiploc, :primary_key => :tiploc_code, :foreign_key => :tiploc_code

  validates_presence_of :daily_schedule_uuid
  validates_inclusion_of :location_type, :in => ['LO','LI','LT']
  validates_presence_of :tiploc_code
  validates_inclusion_of :cancelled, :in => [nil,true,false]


  # Returns true if this location is a publically advertised location, for
  # example, the origin or destination, calling points and pick-up or
  # set-down points

  def is_public?
    ['TB','TF','T','D','U'].include? self.activity
  end


  # Returns true if this location is to pick up passengers only

  def pickup_only?
    self.activity == "U"
  end


  # Returns true if this location is to set down passengers only

  def setdown_only?
    self.activity == "D"
  end


  # Returns true if the schedule starts at this location

  def is_origin?
    self.activity == "TB"
  end


  # Returns true if the schedule finishes at this location

  def is_destination?
    self.activity == "TF"
  end

end
