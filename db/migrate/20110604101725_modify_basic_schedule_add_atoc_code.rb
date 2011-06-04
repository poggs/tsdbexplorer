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

class ModifyBasicScheduleAddAtocCode < ActiveRecord::Migration

  def self.up
    add_column :basic_schedules, :uic_code, :string, :limit => 5
    add_column :basic_schedules, :atoc_code, :string, :limit => 2
    add_column :basic_schedules, :ats_code, :string, :limit => 1
    add_column :basic_schedules, :rsid, :string, :limit => 8
    add_column :basic_schedules, :data_source, :string, :limit => 1
  end

  def self.down
    remove_column :basic_schedules, :uic_code
    remove_column :basic_schedules, :atoc_code
    remove_column :basic_schedules, :ats_code
    remove_column :basic_schedules, :rsid
    remove_column :basic_schedules, :data_source
  end

end
