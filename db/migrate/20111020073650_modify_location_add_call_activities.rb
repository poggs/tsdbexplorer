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

class ModifyLocationAddCallActivities < ActiveRecord::Migration

  def self.up

    remove_column :locations, :activity

    add_column :locations, :activity_ae, :boolean
    add_column :locations, :activity_bl, :boolean
    add_column :locations, :activity_minusd, :boolean
    add_column :locations, :activity_hh, :boolean
    add_column :locations, :activity_kc, :boolean
    add_column :locations, :activity_ke, :boolean
    add_column :locations, :activity_kf, :boolean
    add_column :locations, :activity_ks, :boolean
    add_column :locations, :activity_op, :boolean
    add_column :locations, :activity_or, :boolean
    add_column :locations, :activity_pr, :boolean
    add_column :locations, :activity_rm, :boolean
    add_column :locations, :activity_rr, :boolean
    add_column :locations, :activity_minust, :boolean
    add_column :locations, :activity_tb, :boolean
    add_column :locations, :activity_tf, :boolean
    add_column :locations, :activity_ts, :boolean
    add_column :locations, :activity_tw, :boolean
    add_column :locations, :activity_minusu, :boolean
    add_column :locations, :activity_a, :boolean
    add_column :locations, :activity_c, :boolean
    add_column :locations, :activity_d, :boolean
    add_column :locations, :activity_e, :boolean
    add_column :locations, :activity_g, :boolean
    add_column :locations, :activity_h, :boolean
    add_column :locations, :activity_k, :boolean
    add_column :locations, :activity_l, :boolean
    add_column :locations, :activity_n, :boolean
    add_column :locations, :activity_r, :boolean
    add_column :locations, :activity_s, :boolean
    add_column :locations, :activity_t, :boolean
    add_column :locations, :activity_u, :boolean
    add_column :locations, :activity_w, :boolean
    add_column :locations, :activity_x, :boolean

    add_column :daily_schedule_locations, :activity_ae, :boolean
    add_column :daily_schedule_locations, :activity_bl, :boolean
    add_column :daily_schedule_locations, :activity_minusd, :boolean
    add_column :daily_schedule_locations, :activity_hh, :boolean
    add_column :daily_schedule_locations, :activity_kc, :boolean
    add_column :daily_schedule_locations, :activity_ke, :boolean
    add_column :daily_schedule_locations, :activity_kf, :boolean
    add_column :daily_schedule_locations, :activity_ks, :boolean
    add_column :daily_schedule_locations, :activity_op, :boolean
    add_column :daily_schedule_locations, :activity_or, :boolean
    add_column :daily_schedule_locations, :activity_pr, :boolean
    add_column :daily_schedule_locations, :activity_rm, :boolean
    add_column :daily_schedule_locations, :activity_rr, :boolean
    add_column :daily_schedule_locations, :activity_minust, :boolean
    add_column :daily_schedule_locations, :activity_tb, :boolean
    add_column :daily_schedule_locations, :activity_tf, :boolean
    add_column :daily_schedule_locations, :activity_ts, :boolean
    add_column :daily_schedule_locations, :activity_tw, :boolean
    add_column :daily_schedule_locations, :activity_minusu, :boolean
    add_column :daily_schedule_locations, :activity_a, :boolean
    add_column :daily_schedule_locations, :activity_c, :boolean
    add_column :daily_schedule_locations, :activity_d, :boolean
    add_column :daily_schedule_locations, :activity_e, :boolean
    add_column :daily_schedule_locations, :activity_g, :boolean
    add_column :daily_schedule_locations, :activity_h, :boolean
    add_column :daily_schedule_locations, :activity_k, :boolean
    add_column :daily_schedule_locations, :activity_l, :boolean
    add_column :daily_schedule_locations, :activity_n, :boolean
    add_column :daily_schedule_locations, :activity_r, :boolean
    add_column :daily_schedule_locations, :activity_s, :boolean
    add_column :daily_schedule_locations, :activity_t, :boolean
    add_column :daily_schedule_locations, :activity_u, :boolean
    add_column :daily_schedule_locations, :activity_w, :boolean
    add_column :daily_schedule_locations, :activity_x, :boolean

  end

  def self.down

    add_column :locations, :activity, :string, :limit => 12

    remove_column :locations, :activity_ae
    remove_column :locations, :activity_bl
    remove_column :locations, :activity_minusd
    remove_column :locations, :activity_hh
    remove_column :locations, :activity_kc
    remove_column :locations, :activity_ke
    remove_column :locations, :activity_kf
    remove_column :locations, :activity_ks
    remove_column :locations, :activity_op
    remove_column :locations, :activity_or
    remove_column :locations, :activity_pr
    remove_column :locations, :activity_rm
    remove_column :locations, :activity_rr
    remove_column :locations, :activity_minust
    remove_column :locations, :activity_tb
    remove_column :locations, :activity_tf
    remove_column :locations, :activity_ts
    remove_column :locations, :activity_tw
    remove_column :locations, :activity_minusu
    remove_column :locations, :activity_a
    remove_column :locations, :activity_c
    remove_column :locations, :activity_d
    remove_column :locations, :activity_e
    remove_column :locations, :activity_g
    remove_column :locations, :activity_h
    remove_column :locations, :activity_k
    remove_column :locations, :activity_l
    remove_column :locations, :activity_n
    remove_column :locations, :activity_r
    remove_column :locations, :activity_s
    remove_column :locations, :activity_t
    remove_column :locations, :activity_u
    remove_column :locations, :activity_w
    remove_column :locations, :activity_x

    remove_column :daily_schedule_locations, :activity_ae
    remove_column :daily_schedule_locations, :activity_bl
    remove_column :daily_schedule_locations, :activity_minusd
    remove_column :daily_schedule_locations, :activity_hh
    remove_column :daily_schedule_locations, :activity_kc
    remove_column :daily_schedule_locations, :activity_ke
    remove_column :daily_schedule_locations, :activity_kf
    remove_column :daily_schedule_locations, :activity_ks
    remove_column :daily_schedule_locations, :activity_op
    remove_column :daily_schedule_locations, :activity_or
    remove_column :daily_schedule_locations, :activity_pr
    remove_column :daily_schedule_locations, :activity_rm
    remove_column :daily_schedule_locations, :activity_rr
    remove_column :daily_schedule_locations, :activity_minust
    remove_column :daily_schedule_locations, :activity_tb
    remove_column :daily_schedule_locations, :activity_tf
    remove_column :daily_schedule_locations, :activity_ts
    remove_column :daily_schedule_locations, :activity_tw
    remove_column :daily_schedule_locations, :activity_minusu
    remove_column :daily_schedule_locations, :activity_a
    remove_column :daily_schedule_locations, :activity_c
    remove_column :daily_schedule_locations, :activity_d
    remove_column :daily_schedule_locations, :activity_e
    remove_column :daily_schedule_locations, :activity_g
    remove_column :daily_schedule_locations, :activity_h
    remove_column :daily_schedule_locations, :activity_k
    remove_column :daily_schedule_locations, :activity_l
    remove_column :daily_schedule_locations, :activity_n
    remove_column :daily_schedule_locations, :activity_r
    remove_column :daily_schedule_locations, :activity_s
    remove_column :daily_schedule_locations, :activity_t
    remove_column :daily_schedule_locations, :activity_u
    remove_column :daily_schedule_locations, :activity_w
    remove_column :daily_schedule_locations, :activity_x

  end

end
