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

=begin rdoc

A model object representing a CIF extract file imported in to the database.

The following data is recorded from each CIF extract processed:

  * file_ref: File reference (e.g. DFTESTA)
  * extract_timestamp: The date and time of the extract
  * start_date, end_date: The start and end dates of schedule information included in the CIF extract
  * update_indicator: Either 'F' for a full extract, or 'U' for an update extract

CIF 'update' extracts contain a set of changes from the previous extract, and must be applied in order.  The last letter of the file_ref starts from A and increments to Z, wrapping around to A, and this determines the relative ordering of the extract.

=end

class CifFile < ActiveRecord::Base

  validates_presence_of :file_ref
  validates_format_of :file_ref, :with => /^[CD]F[A-Z]{5}/
  validates_presence_of :extract_timestamp
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :update_indicator
  validates_inclusion_of :update_indicator, :in => [ 'F', 'U' ]

end
