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

class Location < ActiveRecord::Base

  validates_presence_of :tiploc_code

  validates_inclusion_of :location_type, :in => ['LO', 'LI', 'LT']


  # Validations for origin locations

  validates_presence_of :departure, :if => Proc.new { |object| object.location_type == 'LO' }
  validates_inclusion_of :arrival, :in => [ nil ], :if => Proc.new { |object| object.location_type == 'LO' }
  validates_inclusion_of :public_arrival, :in => [ nil ], :if => Proc.new { |object| object.location_type == 'LO' }
  validates_inclusion_of :path, :in => [ nil ], :if => Proc.new { |object| object.location_type == 'LO' }


  # Validations for terminating locations

  validates_presence_of :arrival, :if => Proc.new { |object| object.location_type == 'LT' }
  validates_inclusion_of :departure, :in => [ nil ], :if => Proc.new { |object| object.location_type == 'LT' }
  validates_inclusion_of :public_departure, :in => [ nil ], :if => Proc.new { |object| object.location_type == 'LT' }
  validates_inclusion_of :line, :in => [ nil ], :if => Proc.new { |object| object.location_type == 'LT' }

  belongs_to :basic_schedule, :primary_key => :uuid, :foreign_key => :basic_schedule_uuid
  has_one :tiploc, :primary_key => :tiploc_code, :foreign_key => :tiploc_code

end
