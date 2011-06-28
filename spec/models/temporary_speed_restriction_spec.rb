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

describe TemporarySpeedRestriction do

  it "should be valid with all fields populated" do
    valid_values = { :tsr_id => 71655, :route_group_name => 'Foo', :route_code => 'ZZ9999', :route_order => 1234, :tsr_reference => 'T2009/12345', :from_location => 'Fooington', :to_location => 'Bar LC', :line_name => 'Down Main', :subunit_type => 'chains', :mileage_from => 46, :subunit_from => 54, :mileage_to => 46, :subunit_to => 60, :moving_mileage => '0', :passenger_speed => 70, :freight_speed => 50, :valid_from => DateTime.parse('2009-06-01 10:00:00'), :valid_to => DateTime.parse('2010-04-26 10:00:00'), :reason => 'Condition of Track', :requestor => 'InfraCo Maintenance Division', :comments => 'Example comment', :direction => 'down' }
    TemporarySpeedRestriction.new(valid_values).should be_valid
  end

  it "should not be valid with required fields missing" do

    valid_values = { :tsr_id => 71655, :route_group_name => 'Foo', :route_code => 'ZZ9999', :route_order => 1234, :tsr_reference => 'T2009/12345', :from_location => 'Fooington', :to_location => 'Bar LC', :line_name => 'Down Main', :subunit_type => 'chains', :mileage_from => 46, :subunit_from => 54, :mileage_to => 46, :subunit_to => 60, :moving_mileage => '0', :passenger_speed => 70, :freight_speed => 50, :valid_from => DateTime.parse('2009-06-01 10:00:00'), :valid_to => DateTime.parse('2010-04-26 10:00:00'), :reason => 'Condition of Track', :requestor => 'InfraCo Maintenance Division', :comments => 'Example comment', :direction => 'down' }
    tsr = TemporarySpeedRestriction.new(valid_values)

    valid_values.keys.each do |k|
      original_value = tsr.send(k)
      tsr[k] = nil
      tsr.should_not be_valid
      tsr[k] = ""
      tsr.should_not be_valid
      tsr[k] = original_value
    end

  end

end
