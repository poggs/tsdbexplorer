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

  validates_presence_of :main_train_uid
  validates_format_of :main_train_uid, :with => /^[A-Z]\d{5}$/
  validates_presence_of :assoc_train_uid
  validates_format_of :assoc_train_uid, :with => /^[A-Z]\d{5}$/
  validates_presence_of :association_start_date
  validates_presence_of :association_end_date
  validates_inclusion_of :assoc_type, :in => ['P','O']
  validates_inclusion_of :stp_indicator, :in => ['C','N','P','O']

  validate :valid_start_and_end_dates
  validate :valid_at_least_one_day

  def valid_start_and_end_dates
    if !self.association_start_date.nil? && !self.association_end_date.nil?
      if self.association_start_date > self.association_end_date
        errors.add(:association_start_date, "cannot occur after the end date")
      end
    end
  end

  def valid_at_least_one_day
    is_valid = false
    [:valid_mo, :valid_tu, :valid_we, :valid_th, :valid_fr, :valid_sa, :valid_su].each do |field|
      is_valid = true if self.send(field) == true
    end
    if is_valid == false
      errors.add(:valid_mo, 'must be valid for at least one day')
    end
  end

end
