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

class CreateDailySchedules < ActiveRecord::Migration

  def self.up
    create_table :daily_schedules do |t|
      t.string     :uuid, :limit => 36
      t.date       :runs_on
      t.timestamp  :cancelled
      t.string     :cancellation_reason, :limit => 2
      t.string     :status, :limit => 1
      t.string     :train_uid, :limit => 6
      t.string     :category, :limit => 2
      t.string     :train_identity, :limit => 4
      t.string     :train_identity_unique, :limit => 10
      t.string     :headcode, :limit => 4
      t.string     :service_code, :limit => 8
      t.string     :portion_id, :limit => 1
      t.string     :power_type, :limit => 3
      t.string     :timing_load, :limit => 4
      t.string     :speed, :limit => 3
      t.string     :operating_characteristics, :limit => 6
      t.string     :train_class, :limit => 1
      t.string     :sleepers, :limit => 1
      t.string     :reservations, :limit => 1
      t.string     :catering_code, :limit => 1
      t.string     :service_branding, :limit => 1
      t.string     :stp_indicator, :limit => 1
      t.string     :uic_code, :limit => 5
      t.string     :atoc_code, :limit => 2
      t.string     :ats_code, :limit => 1
      t.string     :rsid, :limit => 8
      t.string     :data_source, :limit => 1
      t.timestamps
    end

    add_index(:daily_schedules, :train_identity_unique)

  end

  def self.down
    drop_table :daily_schedules
  end

end
