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

class Association < ActiveRecord::Base

  validates_format_of :main_train_uid, :with => /^[A-Z]\d{5}$/
  validates_format_of :assoc_train_uid, :with => /^[A-Z]\d{5}$/
  validates_presence_of :date
  validates_inclusion_of :category, :in => [ 'JJ', 'VV', 'NP', '  ' ]
  validates_inclusion_of :date_indicator, :in => [ 'S', 'N', 'P', ' ' ]
  validates_presence_of :location
  validates_numericality_of :base_location_suffix, :greater_than => 0, :allow_blank => true
  validates_numericality_of :assoc_location_suffix, :greater_than => 0, :allow_blank => true
  validates_inclusion_of :diagram_type, :in => [ 'T' ]
  validates_inclusion_of :assoc_type, :in => [ 'P', 'O', ' ' ]

end
