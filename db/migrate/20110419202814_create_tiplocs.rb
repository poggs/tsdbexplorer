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
#  $Id: 20110419202814_create_tiplocs.rb 109 2011-04-19 21:03:03Z pwh $
#

=begin rdoc

Rails migration to generate the Tiploc model

=end

class CreateTiplocs < ActiveRecord::Migration

  def self.up

    create_table :tiplocs do |t|
      t.string     :tiploc_code, :limit => 7
      t.string     :nalco, :limit => 6
      t.string     :tps_description, :limit => 26
      t.string     :stanox, :limit => 5
      t.string     :crs_code, :limit => 3
      t.string     :description, :limit => 16
      t.timestamps
    end

    add_index(:tiplocs, :tiploc_code, :unique => :true)
    add_index(:tiplocs, :crs_code)

  end

  def self.down
    drop_table :tiplocs
  end

end
