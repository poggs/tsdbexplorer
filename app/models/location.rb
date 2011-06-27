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

  validates_presence_of :departure, :if => Proc.new { |object| object.location_type == 'LO' || (object.location_type == 'LI' && object.arrival) }
  validates_inclusion_of :arrival, :in => [ nil ], :if => Proc.new { |object| object.location_type == 'LO' || (object.location_type == 'LI' && object.pass) }
  validates_inclusion_of :public_arrival, :in => [ nil ], :if => Proc.new { |object| object.location_type == 'LO' }
  validates_inclusion_of :path, :in => [ nil ], :if => Proc.new { |object| object.location_type == 'LO' }


  # Validations for intermediate locations

  validates_presence_of :pass, :if => Proc.new { |object| object.location_type == "LI" && object.arrival.nil? && object.departure.nil? }


  # Validations for terminating locations

  validates_presence_of :arrival, :if => Proc.new { |object| (object.location_type == 'LI' && object.departure) || object.location_type == 'LT' }
  validates_inclusion_of :departure, :in => [ nil ], :if => Proc.new { |object| object.location_type == 'LT' || (object.location_type == 'LI' && object.pass) }
  validates_inclusion_of :public_departure, :in => [ nil ], :if => Proc.new { |object| object.location_type == 'LT' }
  validates_inclusion_of :line, :in => [ nil ], :if => Proc.new { |object| object.location_type == 'LT' }

  belongs_to :basic_schedule, :primary_key => :uuid, :foreign_key => :basic_schedule_uuid
  has_one :tiploc, :primary_key => :tiploc_code, :foreign_key => :tiploc_code


  def arrival=(value)
    write_attribute(:arrival, value.nil? ? nil : value.strip)
  end

  def public_arrival=(value)
    write_attribute(:public_arrival, value.nil? ? nil : value.strip)
  end

  def pass=(value)
    write_attribute(:pass, value.nil? ? nil : value.strip)
  end

  def departure=(value)
    write_attribute(:departure, value.nil? ? nil : value.strip)
  end

  def public_departure=(value)
    write_attribute(:public_departure, value.nil? ? nil : value.strip)
  end

end
