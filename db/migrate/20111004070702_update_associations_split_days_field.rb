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

class UpdateAssociationsSplitDaysField < ActiveRecord::Migration

  def self.up
    remove_column :associations, :association_days
    add_column :associations, :valid_mo, :boolean
    add_column :associations, :valid_tu, :boolean
    add_column :associations, :valid_we, :boolean
    add_column :associations, :valid_th, :boolean
    add_column :associations, :valid_fr, :boolean
    add_column :associations, :valid_sa, :boolean
    add_column :associations, :valid_su, :boolean
  end

  def self.down
    remove_column :associations, :valid_mo
    remove_column :associations, :valid_tu
    remove_column :associations, :valid_we
    remove_column :associations, :valid_th
    remove_column :associations, :valid_fr
    remove_column :associations, :valid_sa
    remove_column :associations, :valid_su
    add_column :associations, :association_days, :string, :limit => 7
  end

end
