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

  has_many :locations, :primary_key => :uuid, :foreign_key => :basic_schedule_uuid, :dependent => :delete_all

  scope :runs_on_by_uid_and_date, lambda { |uid,date| where(:train_uid => uid).where('? BETWEEN runs_from AND runs_to', date).runs_on_wday(Date.parse(date).wday).order("runs_to - runs_from").limit(1) }
  scope :runs_on_by_train_identity_and_date, lambda { |identity,date| where('train_identity_unique = ? AND ? BETWEEN runs_from AND runs_to', uid, date).order("runs_to - runs_from").limit(1) }

  scope :runs_on_wday, lambda { |wday| where([ :runs_su, :runs_mo, :runs_tu, :runs_we, :runs_th, :runs_fr, :runs_sa ][wday] => true) }
  scope :runs_on, lambda { |date| where('? BETWEEN runs_from AND runs_to', date).runs_on_wday(Date.parse(date).wday) }
  scope :all_schedules_by_uid, lambda { |train_uid| where(:train_uid => train_uid).order('stp_indicator DESC') }

  def realtime_for(date)
    DailySchedule.where(:train_uid => self.train_uid, :runs_on => date).first
  end

  def origin
    self.locations.where(:location_type => 'LO').first
  end

  def terminate
    self.locations.where(:location_type => 'LT').first
  end

  def is_stp_cancelled?
    self.stp_indicator == "C"
  end

end
