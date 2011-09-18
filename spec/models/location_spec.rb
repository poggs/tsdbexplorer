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

require 'spec_helper'

describe Location do

  it "should return true if a location is for pick-up only" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/activity_record_test.cif')
    euston_to_wolverhampton = BasicSchedule.runs_on_by_uid_and_date('P64437', '2011-05-22').first

    watford_junction = euston_to_wolverhampton.locations.where(:tiploc_code => 'WATFDJ').first
    watford_junction.is_public?.should be_true
    watford_junction.pickup_only?.should be_true
    watford_junction.setdown_only?.should_not be_true

  end

  it "should return true if a location is for set-down only" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/activity_record_test.cif')
    wolverhampton_to_euston = BasicSchedule.runs_on_by_uid_and_date('P64027', '2011-05-22').first

    watford_junction = wolverhampton_to_euston.locations.where(:tiploc_code => 'WATFDJ').first
    watford_junction.is_public?.should be_true
    watford_junction.pickup_only?.should_not be_true
    watford_junction.setdown_only?.should be_true

  end

  it "should return true if a location is a publically advertised calling point" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/activity_record_test.cif')
    willesden_to_stratford = BasicSchedule.runs_on_by_uid_and_date('L97307', '2011-05-22').first

    willesden_bay_to_high_level = willesden_to_stratford.locations.where(:tiploc_code => 'WLSDLUC').first
    willesden_bay_to_high_level.is_public?.should_not be_true
    willesden_bay_to_high_level.pickup_only?.should_not be_true
    willesden_bay_to_high_level.setdown_only?.should_not be_true

  end

  it "should return true if the schedule starts at this location" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/activity_record_test.cif')
    willesden_to_stratford = BasicSchedule.runs_on_by_uid_and_date('L97307', '2011-05-22').first

    willesden_ll_bay = willesden_to_stratford.locations.where(:tiploc_code => 'WLSDNJL').first
    willesden_ll_bay.is_origin?.should be_true
    willesden_ll_bay.is_destination?.should_not be_true

  end

  it "should return true if the schedule finishes at this location" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/activity_record_test.cif')
    willesden_to_stratford = BasicSchedule.runs_on_by_uid_and_date('L97307', '2011-05-22').first

    stratford = willesden_to_stratford.locations.where(:tiploc_code => 'STFD').first
    stratford.is_origin?.should_not be_true
    stratford.is_destination?.should be_true

  end

end
