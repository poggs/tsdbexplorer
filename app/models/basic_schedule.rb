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

class BasicSchedule < ActiveRecord::Base

  validates_format_of :train_uid, :with => /[A-Z]\d{5}/
  validates_inclusion_of :status, :in => ['B', 'F', 'P', 'S', 'T', '1', '2', '3', '4', '5']
  validates_format_of :train_identity, :with => /\d[A-Z]\d{2}/
  validates_format_of :headcode, :with => /\d{4}/, :allow_nil => true, :allow_blank => true
  validates_format_of :service_code, :with => /\d{4}/, :allow_nil => true, :allow_blank => true
  validates_inclusion_of :portion_id, :in => ['0', '1', '2', '4', '8', 'Z'], :allow_nil => true, :allow_blank => true
  validates_format_of :speed, :with => /\d+/, :allow_nil => true, :allow_blank => true
  validates_inclusion_of :operating_characteristics, :in => ['B', 'C', 'D', 'E', 'G', 'M', 'P', 'Q', 'R', 'S', 'Y', 'Z', ' '], :allow_nil => true, :allow_blank => true
  validates_inclusion_of :train_class, :in => ['B', 'S'], :allow_blank => true, :allow_nil => true
  validates_inclusion_of :sleepers, :in => ['B', 'F', 'S'], :allow_blank => true
  validates_inclusion_of :reservations, :in => ['A', 'E', 'R', 'S'], :allow_blank => true
  validates_inclusion_of :connection_indicator, :in => ['C', 'S', 'X'], :allow_blank => true, :allow_nil => true
  validates_format_of :catering_code, :with => /[CFHMRT]{0,2}/, :allow_blank => true
  validates_inclusion_of :service_branding, :in => ['E', 'U'], :allow_blank => true

  has_many :locations, :primary_key => :uuid, :foreign_key => :basic_schedule_uuid

end
