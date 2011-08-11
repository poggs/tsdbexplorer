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

describe "lib/tsdbexplorer/cif.rb" do

  # Record parsing

  it "should correctly parse a CIF 'BS' record" do
    expected_data = {:timing_load=>"321 ", :status=>"P", :train_uid=>"C43391", :transaction_type=>"N", :connection_indicator=>nil, :category=>"OO", :bh_running=>nil, :stp_indicator=>"P", :speed=>"100", :catering_code=>nil, :headcode=>nil, :operating_characteristics=>nil, :service_branding=>nil, :service_code=>"22209000", :train_class=>"B", :runs_from=>"2010-12-12", :portion_id=>nil, :train_identity=>"2N53", :sleepers=>nil, :runs_to=>"2011-05-15", :power_type=>"EMU", :reservations=>"S", :runs_mo=>"0", :runs_tu=>"0", :runs_we=>"0", :runs_th=>"0", :runs_fr=>"0", :runs_sa=>"0", :runs_su=>"1"}
    parsed_record = TSDBExplorer::CIF::parse_record('BSNC433911012121105150000001 POO2N53    122209000 EMU321 100      B S          P')
    parsed_record.should be_a TSDBExplorer::CIF::BasicScheduleRecord
    expected_data.collect.each { |k,v| parsed_record.send(k).should eql(v) }
  end

  it "should correctly parse a CIF 'BX' record" do
    expected_data = {:uic_code=>"48488", :atoc_code=>"ZZ", :ats_code=>"Y", :rsid=>nil, :data_source=>nil, :traction_class=>nil}
    parsed_record = TSDBExplorer::CIF::parse_record('BX    48488ZZY                                                                  ')
    parsed_record.should be_a TSDBExplorer::CIF::BasicScheduleExtendedRecord
    expected_data.collect.each { |k,v| parsed_record.send(k).should eql(v) }
  end

  it "should correctly parse a CIF 'LO' record" do
    expected_data = {:performance_allowance=>nil, :platform=>"3", :departure=>"0910 ", :public_departure=>"0000", :record_identity=>"LO", :engineering_allowance=>nil, :line=>nil, :tiploc_code=>"PENZNCE", :pathing_allowance=>nil, :activity=>"TBRMA -D", :tiploc_instance=>nil}
    parsed_record = TSDBExplorer::CIF::parse_record('LOPENZNCE 0910 00003         TBRMA -D                                           ')
    expected_data.collect.each { |k,v| parsed_record[k].should eql(v) }
  end

  it "should correctly parse a CIF 'LI' record" do
    expected_data = {:performance_allowance=>nil, :platform=>"15", :pass=>nil, :path=>nil, :departure=>"1532H", :arrival=>"1429H", :public_departure=>"0000", :public_arrival=>"0000", :record_identity=>"LI", :engineering_allowance=>nil, :line=>"E", :tiploc_code=>"EUSTON", :pathing_allowance=>nil, :activity=>"RMOP", :tiploc_instance=>nil}
    parsed_record = TSDBExplorer::CIF::parse_record('LIEUSTON  1429H1532H     0000000015 E     RMOP                                  ')
    expected_data.collect.each { |k,v| parsed_record[k].should eql(v) }
  end

  it "should correctly parse a CIF 'LT' record" do
    expected_data = {:platform=>nil, :path=>nil, :arrival=>"0417 ", :public_arrival=>"0000", :record_identity=>"LT", :tiploc_code=>"DITTFLR", :activity=>"TFPR", :tiploc_instance=>nil}
    parsed_record = TSDBExplorer::CIF::parse_record('LTDITTFLR 0417 0000      TFPR                                                   ')
    expected_data.collect.each { |k,v| parsed_record[k].should eql(v) }
  end

  it "should correctly parse a CIF 'CR' record" do
    expected_data = {:timing_load=>"350 ", :connection_indicator=>nil, :speed=>"100", :course_indicator=>"1", :record_identity=>"CR", :catering_code=>nil, :headcode=>"2130", :rsid=>nil, :operating_characteristics=>nil, :tiploc_code=>"NMPTN", :service_branding=>nil, :service_code=>"22209000", :train_identity=>"1U30", :train_class=>"B", :traction_class=>nil, :portion_id=>nil, :sleepers=>nil, :tiploc_instance=>nil, :uic_code=>nil, :power_type=>"EMU", :reservations=>"S", :category=>"XX"}
    parsed_record = TSDBExplorer::CIF::parse_record('CRNMPTN   XX1U302130122209000 EMU350 100      B S                               ')
    expected_data.collect.each { |k,v| parsed_record[k].should eql(v) }
  end


  # File parsing - error and edge conditions

  it "should handle gracefully a nonexistent CIF file" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/DOES_NOT_EXIST.cif') }.should raise_error
  end

  it "should reject an empty CIF file" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/blank_file.cif') }.should raise_error
  end

  it "should reject a CIF file with an unknown record" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/unknown_record_type.cif') }.should raise_error
  end

  it "should permit a CIF file with only an HD and ZZ record" do
    expected_data = {:tiploc=>{:insert=>0, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/header_and_trailer.cif').should eql(expected_data)
  end


  # TIPLOC Record processing

  it "should process TI records from a CIF file" do
    Tiploc.all.count.should eql(0)
    expected_data = {:tiploc=>{:insert=>1, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ti.cif').should eql(expected_data)
    Tiploc.all.count.should eql(1)
    
    expected_record = {:crs_code=>"EUS", :tps_description=>"LONDON EUSTON", :stanox=>"72410", :nalco=>"144400", :tiploc_code=>"EUSTON", :description=>"LONDON EUSTON"}
    actual_record = Tiploc.find_by_stanox('72410').attributes

    expected_record.each do |k,v|
      actual_record[k.to_s].should eql(v)
    end

  end

  it "should not allow TA records in a CIF full extract" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ta_full.cif') }.should raise_error
  end

  it "should process TA records from a CIF file" do
    expected_data_part_1 = {:tiploc=>{:insert=>1, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ta_part1.cif').should eql(expected_data_part_1)
    expected_data_part_2 = {:tiploc=>{:insert=>0, :delete=>0, :amend=>1}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ta_part2.cif').should eql(expected_data_part_2)
    Tiploc.count.should eql(1)

    expected_record = {:description=>"SMITHAM", :stanox=>"87705", :crs_code=>"SMI", :tiploc_code=>"SMITHAM", :tps_description=>"SMITHAM", :nalco=>"638600"}
    actual_record = Tiploc.find_by_crs_code('SMI').attributes

    expected_record.each do |k,v|
      actual_record[k.to_s].should eql(v)
    end

  end

  it "should not allow TD records in a CIF full extract" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_td_full.cif') }.should raise_error
  end

  it "should process TD records from a CIF file" do
    expected_data_part_1 = {:tiploc=>{:insert=>2, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_td_part1.cif').should eql(expected_data_part_1)
    expected_data_part_2 = {:tiploc=>{:insert=>0, :delete=>1, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_td_part2.cif').should eql(expected_data_part_2)
    Tiploc.count.should eql(1)
    Tiploc.find_by_tiploc_code('WATFDJ').should_not be_nil
  end


  # Basic Schedule (New) record processing

  it "should process BS 'new' records in a CIF full extract" do
    expected_data_part_1 = {:tiploc=>{:insert=>18, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>1, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif').should eql(expected_data_part_1)
    BasicSchedule.count.should eql(1)
    Location.count.should eql(18)
    Location.first.tiploc_code.should eql('EUSTON')
    Location.last.tiploc_code.should eql('NMPTN')
  end

  it "should process BS 'new' records in a CIF update extract" do
    expected_data_part_1 = {:tiploc=>{:insert=>18, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>1, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_updateextract.cif').should eql(expected_data_part_1)
    BasicSchedule.count.should eql(1)
    Location.count.should eql(18)
    Location.first.tiploc_code.should eql('EUSTON')
    Location.last.tiploc_code.should eql('NMPTN')    
  end

  it "should not allow BS 'delete' records in a CIF full extract" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_delete_fullextract.cif') }.should raise_error
  end

  it "should process BS 'delete' records in a CIF update extract" do
    expected_data_part_1 = {:tiploc=>{:insert=>5, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>1, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_delete_part1.cif').should eql(expected_data_part_1)
    BasicSchedule.count.should eql(1)
    Location.count.should eql(5)
    expected_data_part_2 = {:tiploc=>{:insert=>0, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>1, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_delete_part2.cif').should eql(expected_data_part_2)
    BasicSchedule.count.should eql(0)
    Location.count.should eql(0)
  end

  it "should not allow BS 'revise' records in a CIF full extract" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_revise_fullextract.cif') }.should raise_error
  end

  it "should process BS 'revise' records in a CIF update extract" do
    expected_data_part_1 = {:tiploc=>{:insert=>13, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>1, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_revise_part1.cif').should eql(expected_data_part_1)
    BasicSchedule.count.should eql(1)
    Location.count.should eql(13)
    expected_data_part_2 = {:tiploc=>{:insert=>0, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>1}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_revise_part2.cif').should eql(expected_data_part_2)
    BasicSchedule.count.should eql(1)
    Location.count.should eql(13)
  end

  it "should not allow unknown BS record transaction types in a CIF extract" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_invalid.cif') }.should raise_error
  end


  # Time procesing

  it "should process Basic Schedule arrival, public arrival, passing, departure and public departure times correctly" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    basic_schedule = BasicSchedule.first
    locations = basic_schedule.locations

    # Originating locations must have only a departure time
    locations.first.arrival.should be_nil
    locations.first.public_arrival.should be_nil
    locations.first.pass.should be_nil
    locations.first.departure.should eql('1834 ')
    locations.first.public_departure.should eql('1834')

    # Passing points must have only a passing time
    locations[2].arrival.should be_nil
    locations[2].public_arrival.should be_nil
    locations[2].pass.should eql('1837H')
    locations[2].departure.should be_nil
    locations[2].public_departure.should be_nil    

    # Calling points must have only an arrival, public arrival, departure and public departure time only
    locations[6].arrival.should eql('1850 ')
    locations[6].public_arrival.should eql('1850')
    locations[6].pass.should be_nil
    locations[6].departure.should eql('1851 ')
    locations[6].public_departure.should eql('1851')

    # Terminating locations must have only an arrival and public arrival time
    locations.last.arrival.should eql('1946 ')
    locations.last.public_arrival.should eql('1946')
    locations.last.pass.should be_nil
    locations.last.departure.should be_nil
    locations.last.public_departure.should be_nil
  end


  # Bus and Ship processing

  it "should handle schedules for buses" do
    expected_data = {:tiploc=>{:insert=>3, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>1, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_bus.cif').should eql(expected_data)
    basic_schedule = BasicSchedule.first
    basic_schedule.train_identity.should eql('0B00')
    basic_schedule.status.should eql('B')
    locations = basic_schedule.locations
    basic_schedule.locations.count.should eql(3)
    locations.first.line.should eql('BUS')
  end

  it "should handle schedules for ships" do
    expected_data = {:tiploc=>{:insert=>2, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>1, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_ship.cif').should eql(expected_data)
    basic_schedule = BasicSchedule.first
    basic_schedule.train_identity.should eql('0S00')
    basic_schedule.status.should eql('S')
    locations = basic_schedule.locations
    basic_schedule.locations.count.should eql(2)
  end


  # Schedule processing

  it "should process a complete schedule from a CIF file"

end
