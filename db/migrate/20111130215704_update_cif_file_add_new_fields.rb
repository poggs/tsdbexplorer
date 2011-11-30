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

class UpdateCifFileAddNewFields < ActiveRecord::Migration

  def up
    add_column :cif_files, :file_mainframe_identity, :string, :limit => 20
    add_column :cif_files, :mainframe_username, :string, :limit => 6
    add_column :cif_files, :extract_date, :date
  end

  def down
    remove_column :cif_files, :file_mainframe_identity
    remove_column :cif_files, :mainframe_username
    remove_column :cif_files, :extract_date
  end

end
