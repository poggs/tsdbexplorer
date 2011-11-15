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

class ExtendDataSourceField < ActiveRecord::Migration

  def self.up
    remove_column :basic_schedules, :data_source
    add_column :basic_schedules, :data_source, :string, :limit => 16
    remove_column :daily_schedules, :data_source
    add_column :daily_schedules, :data_source, :string, :limit => 16
  end

  def self.down
    remove_column :basic_schedules, :data_source
    add_column :basic_schedules, :data_source, :string, :limit => 1
    remove_column :daily_schedules, :data_source
    add_column :daily_schedules, :data_source, :string, :limit => 1
  end

end
