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

class DailySchedule < ActiveRecord::Base

  has_many :locations, :class_name => 'DailyScheduleLocation', :primary_key => :uuid, :foreign_key => :daily_schedule_uuid

  scope :runs_on_by_uid_and_date, lambda { |uid,date| where(:train_uid => uid).where(:runs_on => date) }

  def origin
    if self.locations.first.cancelled?
      self.locations.where(:location_type => 'LO').where(:cancelled => nil).order(:id).first
    else
      self.locations.order(:id).first
    end
  end

  def terminate
    if self.locations.last.cancelled?
      self.locations.where(:location_type => 'LT').where(:cancelled => nil).order(:id).last
    else
      self.locations.order(:id).last
    end
  end


  # Return true if the train has departed from its originating location

  def departed_origin?
    self.locations.first.actual_departure.nil? ? false : true
  end


  # Return true is the train has terminated at its destination

  def terminated?
    self.locations.last.actual_arrival.nil? ? false : true
  end

end
