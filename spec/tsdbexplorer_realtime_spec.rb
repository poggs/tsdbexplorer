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

describe "lib/tsdbexplorer/realtime.rb" do

  before(:each) do
    $REDIS.flushdb
  end

  it "should put the site in to maintenance mode" do
    TSDBExplorer::Realtime::set_maintenance_mode('Test message')
  end

  it "should take the site out of maintenance mode" do
    TSDBExplorer::Realtime::clear_maintenance_mode
  end

  it "should cache TIPLOC data keyed on TIPLOC" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ti.cif')
    expected_data = { 'description' => 'LONDON EUSTON', 'stanox' => '72410', 'crs_code' => 'EUS' }
    $REDIS.hgetall('TIPLOC:EUSTON').should eql(expected_data)
  end

  it "should cache TIPLOC data keyed on description" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ti.cif')
    expected_data = { 'tiploc' => 'EUSTON', 'stanox' => '72410', 'crs_code' => 'EUS' }
    $REDIS.hgetall('LOCATION:CIF:LONDON EUSTON').should eql(expected_data)
  end

  it "should cache MSNF data keyed on TIPLOC" do
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/london_euston.msn')
    expected_data = { 'tiploc' => 'EUSTON', 'description' => 'LONDON EUSTON', 'crs_code' => 'EUS' }
    $REDIS.hgetall('TIPLOC:EUSTON').should eql(expected_data)
  end

  it "should cache MSNF data keyed on description" do
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/london_euston.msn')
    expected_data = { 'description' => 'LONDON EUSTON', 'tiploc' => 'EUSTON', 'crs_code' => 'EUS' }
    $REDIS.hgetall('LOCATION:LONDON EUSTON').should eql(expected_data)
  end

  it "should cache MSNF data keyed on CRS code with a list of TIPLOCs" do
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/london_euston.msn')
    expected_data = [ 'EUSTON' ]
    $REDIS.lrange('CRS:EUS:TIPLOCS', 0, -1).should eql(expected_data)
  end

  it "should cache MSNF data keyed on CRS code with the station name" do
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/london_euston.msn')
    expected_data = { 'description' => 'LONDON EUSTON' }
    $REDIS.hgetall('CRS:EUS').should eql(expected_data)
  end

  it "should update locations from the TIPLOC table with additional data from the MSNF table" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ti.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/london_euston.msn')
    expected_data = { 'description' => 'LONDON EUSTON', 'stanox' => '72410', 'crs_code' => 'EUS', 'tiploc' => 'EUSTON' }
    $REDIS.hgetall('TIPLOC:EUSTON').should eql(expected_data)
  end

end
