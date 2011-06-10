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

describe "lib/tsdbexplorer.rb" do

  it "should validate a correctly formatted train identity" do

    TSDBExplorer.validate_train_identity("1A99").should be_true
    TSDBExplorer.validate_train_identity("2Z00").should be_true
    TSDBExplorer.validate_train_identity("3C01").should be_true
    TSDBExplorer.validate_train_identity("9O10").should be_true

  end

  it "should reject an incorrectly formed train identity" do

    TSDBExplorer.validate_train_identity(nil).should be_false
    TSDBExplorer.validate_train_identity("").should be_false
    TSDBExplorer.validate_train_identity("0000").should be_false
    TSDBExplorer.validate_train_identity("AAAA").should be_false
    TSDBExplorer.validate_train_identity("foobarbaz").should be_false

  end

  it "should validate a correctly formatted train UID" do

    TSDBExplorer.validate_train_uid("A00000").should be_true
    TSDBExplorer.validate_train_uid("C11111").should be_true
    TSDBExplorer.validate_train_uid("Z99999").should be_true

  end

  it "should reject an incorrectly formatted train UID" do

    TSDBExplorer.validate_train_uid(nil).should be_false
    TSDBExplorer.validate_train_uid("").should be_false
    TSDBExplorer.validate_train_uid("000000").should be_false
    TSDBExplorer.validate_train_uid("AAAAAA").should be_false
    TSDBExplorer.validate_train_uid("foobarbaz").should be_false

  end

  it "should convert a date in YYYYMMDDHHMMSS format to YYYY-MM-DD HH:MM:SS" do

    TSDBExplorer.yyyymmddhhmmss_to_time("19600101120000").should eql(Time.parse("1960-01-01 12:00:00"))
    TSDBExplorer.yyyymmddhhmmss_to_time("19991231235959").should eql(Time.parse("1999-12-31 23:59:59"))
    TSDBExplorer.yyyymmddhhmmss_to_time("20000101000000").should eql(Time.parse("2000-01-01 00:00:00"))
    TSDBExplorer.yyyymmddhhmmss_to_time("20591231235959").should eql(Time.parse("2059-12-31 23:59:59"))

  end

  it "should return nil for an invalid date to be converted to YYYYMMDDHHMMSS format" do

    TSDBExplorer.yyyymmddhhmmss_to_time('00000000000000').should be_nil

  end

  it "should convert a date in DDMMYY format to YYYY-MM-DD" do

    TSDBExplorer.ddmmyy_to_date("010160").should eql("1960-01-01")
    TSDBExplorer.ddmmyy_to_date("311299").should eql("1999-12-31")
    TSDBExplorer.ddmmyy_to_date("010100").should eql("2000-01-01")
    TSDBExplorer.ddmmyy_to_date("311259").should eql("2059-12-31")

  end


  it "should convert a date in YYMMDD format to YYYY-MM-DD" do

    TSDBExplorer.yymmdd_to_date("600101").should eql("1960-01-01")
    TSDBExplorer.yymmdd_to_date("991231").should eql("1999-12-31")
    TSDBExplorer.yymmdd_to_date("000101").should eql("2000-01-01")
    TSDBExplorer.yymmdd_to_date("591231").should eql("2059-12-31")

  end

  it "should convert a date in DDMMYY format to YYMMDD" do

    TSDBExplorer.ddmmyy_to_yymmdd("010160").should eql("600101")
    TSDBExplorer.ddmmyy_to_yymmdd("311299").should eql("991231")
    TSDBExplorer.ddmmyy_to_yymmdd("010100").should eql("000101")
    TSDBExplorer.ddmmyy_to_yymmdd("311259").should eql("591231")

  end

  it "should return a list of dates between two days matching a mask" do

    TSDBExplorer.date_range_to_list("2011-01-01", "2011-01-28", "1000000").should eql([ '2011-01-03', '2011-01-10', '2011-01-17', '2011-01-24' ])
    TSDBExplorer.date_range_to_list("2011-01-01", "2011-01-28", "0000011").should eql([ '2011-01-01', '2011-01-02', '2011-01-08', '2011-01-09', '2011-01-15', '2011-01-16', '2011-01-22', '2011-01-23' ])
    TSDBExplorer.date_range_to_list("2011-01-01", "2011-01-28", "0000000").should eql([])
    TSDBExplorer.date_range_to_list("2011-01-01", "2011-01-05", "0001100").should eql([])

  end

  it "should convert a time in HHMM to HH:MM" do

    TSDBExplorer.normalise_time("0000").should eql("00:00")
    TSDBExplorer.normalise_time("2359").should eql("23:59")

  end

  it "should convert a time in HHMM with an 'H' in to HH:MM:30" do

    TSDBExplorer.normalise_time("0000H").should eql("00:00:30")
    TSDBExplorer.normalise_time("2359H").should eql("23:59:30")

  end

  it "should convert an allowance time to an integer number of seconds" do

    TSDBExplorer.normalise_allowance_time("0").should eql(0)
    TSDBExplorer.normalise_allowance_time("H").should eql(30)
    TSDBExplorer.normalise_allowance_time("1").should eql(60)
    TSDBExplorer.normalise_allowance_time("1H").should eql(90)

  end

  it "should merge a date and a time in to a Time object" do

    TSDBExplorer.normalise_datetime("2011-01-01 0800").should eql(Time.parse("2011-01-01 08:00"))
    TSDBExplorer.normalise_datetime("2011-01-01 2000").should eql(Time.parse("2011-01-01 20:00"))

    TSDBExplorer.normalise_datetime("2011-01-01 0800H").should eql(Time.parse("2011-01-01 08:00:30"))
    TSDBExplorer.normalise_datetime("2011-01-01 2000H").should eql(Time.parse("2011-01-01 20:00:30"))

  end

  it "should calculate the next CIF file reference for a user identity given the previous" do

    TSDBExplorer.next_file_reference('DFTESTA').should eql('DFTESTB')
    TSDBExplorer.next_file_reference('DFTESTB').should eql('DFTESTC')
    TSDBExplorer.next_file_reference('DFTESTZ').should eql('DFTESTA')

  end

  it "should validate a correctly formatted File Mainframe Identity in a CIF HD record" do

    file_mainframe_identity_1 = TSDBExplorer.cif_parse_file_mainframe_identity("TPS.UDFXXXX.PD700101")
    file_mainframe_identity_1.should have_key(:username)
    file_mainframe_identity_1[:username].should eql("DFXXXX")
    file_mainframe_identity_1.should have_key(:extract_date)
    file_mainframe_identity_1[:extract_date].should eql("700101")
    file_mainframe_identity_1.should_not have_key(:error)

    file_mainframe_identity_2 = TSDBExplorer.cif_parse_file_mainframe_identity("TPS.UCFXXXX.PD700101")
    file_mainframe_identity_2.should have_key(:username)
    file_mainframe_identity_2[:username].should eql("CFXXXX")
    file_mainframe_identity_2.should have_key(:extract_date)
    file_mainframe_identity_2[:extract_date].should eql("700101")
    file_mainframe_identity_2.should_not have_key(:error)

  end

  it "should reject an incorrectly formatted File Mainframe Identity in a CIF HD record" do

    file_mainframe_identity_1 = TSDBExplorer.cif_parse_file_mainframe_identity("TPS.Ufoo.PD700101")
    file_mainframe_identity_1.should have_key(:error)
    file_mainframe_identity_1[:error].should_not be_nil

    file_mainframe_identity_2 = TSDBExplorer.cif_parse_file_mainframe_identity("TPS.U.PD700101")
    file_mainframe_identity_2.should have_key(:error)
    file_mainframe_identity_2[:error].should_not be_nil

    file_mainframe_identity_3 = TSDBExplorer.cif_parse_file_mainframe_identity("TPS.UZZXXXX.PD700101")
    file_mainframe_identity_3.should have_key(:error)
    file_mainframe_identity_3[:error].should_not be_nil

    file_mainframe_identity_4 = TSDBExplorer.cif_parse_file_mainframe_identity("TPS.UDFZZZZ.PDfoobar")
    file_mainframe_identity_4.should have_key(:error)
    file_mainframe_identity_4[:error].should_not be_nil

  end

  it "should correctly parse a CIF 'BS' record" do
    expected_data = {:timing_load=>"321 ", :status=>"P", :train_uid=>"C43391", :transaction_type=>"N", :connection_indicator=>nil, :category=>"OO", :bh_running=>nil, :stp_indicator=>"P", :speed=>"100", :catering_code=>nil, :headcode=>nil, :operating_characteristics=>nil, :record_identity=>"BS", :service_branding=>nil, :service_code=>"22209000", :train_class=>"B", :runs_from=>"2010-12-12", :portion_id=>nil, :train_identity=>"2N53", :sleepers=>nil, :runs_to=>"2011-05-15", :power_type=>"EMU", :reservations=>"S", :days_run=>"0000001"}
    parsed_record = TSDBExplorer::CIF::parse_record('BSNC433911012121105150000001 POO2N53    122209000 EMU321 100      B S          P')
    expected_data.collect.each { |k,v| parsed_record[k].should eql(v) }
  end

  it "should correctly parse a CIF 'BX' record" do
    expected_data = {:uic_code=>"48488", :atoc_code=>"ZZ", :ats_code=>"Y", :record_identity=>"BX", :rsid=>nil, :data_source=>nil, :traction_class=>nil}
    parsed_record = TSDBExplorer::CIF::parse_record('BX    48488ZZY                                                                  ')
    expected_data.collect.each { |k,v| parsed_record[k].should eql(v) }
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

  it "should handle gracefully a nonexistant CIF file" do
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

  it "should process TI records from a CIF file" do
    Tiploc.all.count.should eql(0)
    expected_data = {:tiploc=>{:insert=>1, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ti.cif').should eql(expected_data)
    Tiploc.all.count.should eql(1)
  end

  it "should process TA records from a CIF file" do
    Tiploc.all.count.should eql(0)
    expected_data_before = {:tiploc=>{:insert=>1, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ta_part1.cif').should eql(expected_data_before)
    Tiploc.all.count.should eql(1)
    expected_data_after = {:tiploc=>{:insert=>0, :delete=>0, :amend=>1}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ta_part2.cif').should eql(expected_data_after)
    Tiploc.all.count.should eql(1)
  end

  it "should not allow TA records in a CIF full extract" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ta_full.cif') }.should raise_error
  end

  it "should process TA records with a TIPLOC code change from a CIF file" do
    Tiploc.all.count.should eql(0)
    expected_data_before = {:tiploc=>{:insert=>1, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ta_tiploc_change_part1.cif').should eql(expected_data_before)
    Tiploc.all.count.should eql(1)
    expected_data_after = {:tiploc=>{:insert=>0, :delete=>0, :amend=>1}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ta_tiploc_change_part2.cif').should eql(expected_data_after)
    Tiploc.all.count.should eql(1)
  end

  it "should raise an error if a TA record contains an unknown TIPLOC" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ta_unknown_tiploc.cif').should have_key(:error)
  end

  it "should process TD records from a CIF file" do
    Tiploc.all.count.should eql(0)
    expected_data = {:tiploc=>{:insert=>2, :delete=>1, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_td.cif').should eql(expected_data)
    Tiploc.all.count.should eql(1)
  end

  it "should not allow TD records in a CIF full extract" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_td_full.cif') }.should raise_error
  end

  it "should return an error when processing a TD record for an unknown location from a CIF file" do
    Tiploc.all.count.should eql(0)
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_td_unknown.cif').should have_key(:error)
    Tiploc.all.count.should eql(2)
  end

  it "should process new AA records from a CIF file" do
    Association.all.count.should eql(0)
    expected_data = {:tiploc=>{:insert=>0, :delete=>0, :amend=>0}, :association=>{:insert=>7, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_aa_new.cif').should eql(expected_data)
    Association.all.count.should eql(7)
  end

  it "should process delete AA records from a CIF file" do
    Association.all.count.should eql(0)
    expected_data_before = {:tiploc=>{:insert=>0, :delete=>0, :amend=>0}, :association=>{:insert=>7, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_aa_delete_part1.cif').should eql(expected_data_before)
    expected_data_after = {:tiploc=>{:insert=>0, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>1, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_aa_delete_part2.cif').should eql(expected_data_after)
    Association.all.count.should eql(6)
  end

  it "should process revise AA records from a CIF file" do
    Association.all.count.should eql(0)
    expected_data_before = {:tiploc=>{:insert=>0, :amend=>0, :delete=>0}, :schedule=>{:insert=>0, :amend=>0, :delete=>0}, :association=>{:insert=>115, :amend=>0, :delete=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_aa_revise_part1.cif').should eql(expected_data_before)
    expected_data_after = {:tiploc=>{:insert=>0, :amend=>0, :delete=>0}, :schedule=>{:insert=>0, :amend=>0, :delete=>0}, :association=>{:insert=>0, :amend=>2, :delete=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_aa_revise_part2.cif').should eql(expected_data_after)
  end

  it "should reject invalid AA record transaction types in a CIF file" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_aa_invalid.cif') }.should raise_error
  end

  it "should raise an error if a TN record type is found in a CIF file" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_tn.cif') }.should raise_error
  end

  it "should raise an error if a LN record type is found in a CIF file" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ln.cif') }.should raise_error
  end

  it "should not allow BS revise records in a CIF full extract" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_revise_fullextract.cif') }.should raise_error
  end

  it "should not allow BS delete records in a CIF full extract" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_delete_fullextract.cif') }.should raise_error
  end

  it "should process a set of permanent schedule BS/BX/LO/LI/LT records in a CIF file" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new.cif')
    schedule_expected_data = {:timing_load=>"321 ", :status=>"P", :train_uid=>"C43391", :connection_indicator=>nil, :headcode=>nil, :category=>"OO", :speed=>"100", :catering_code=>nil, :operating_characteristics=>nil, :run_date=>Date.parse("2010-12-12").to_date, :service_branding=>nil, :service_code=>"22209000", :train_class=>"B", :portion_id=>nil, :sleepers=>nil, :power_type=>"EMU", :reservations=>"S", :train_identity=>"2N53"}
    schedule = BasicSchedule.first
    schedule_expected_data.collect.each { |k,v| schedule[k].should eql(v) }

    origin_expected_data = {:platform=>"10", :public_departure=>Time.parse('2010-12-12 18:34:00'), :engineering_allowance=>nil, :location_type=>"LO", :pathing_allowance=>nil, :tiploc_code =>"EUSTON", :line=>"C", :activity=>"TB", :performance_allowance=>nil, :departure=>Time.parse('2010-12-12 18:34:00')}
    origin = Location.find(:first, :conditions => { :location_type => 'LO' })
    origin_expected_data.collect.each { |k,v| origin[k].should eql(v) }

    intermediate_expected_data = {:performance_allowance=>nil, :platform=>nil, :pass=>Time.parse('2010-12-12 18:37:00'), :path=>nil, :departure=>nil, :arrival=>nil, :public_departure=>nil, :public_arrival=>nil, :location_type=>"LI", :engineering_allowance=>nil, :line=>nil, :tiploc_code=>"CMDNSTH", :pathing_allowance=>nil, :activity=>nil, :tiploc_instance=>nil}
    intermediate = Location.find(:first, :conditions => { :location_type => 'LI' })
    intermediate_expected_data.collect.each { |k,v| intermediate[k].should eql(v) }

    terminate_expected_data = {:platform=>"3", :arrival=>Time.parse('2010-12-12 19:46:00'), :path=>nil, :public_arrival=>Time.parse('2010-12-12 19:46:00'), :location_type=>"LT", :tiploc_code=>"NMPTN", :activity=>"TF"}
    terminate = Location.find(:first, :conditions => { :location_type => 'LT' })
    terminate_expected_data.collect.each { |k,v| terminate[k].should eql(v) }
  end

  it "should generate and maintain a UUID between a BasicSchedule and each Location in that schedule for each date the train runs" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new.cif')
    first_schedule = BasicSchedule.find(1)
    first_location = Location.find_by_departure(Time.parse('2010-12-12 18:34:00'))
    second_schedule = BasicSchedule.find(2)
    second_location = Location.find_by_departure(Time.parse('2010-12-19 18:34:00'))

    first_schedule.uuid.should eql(first_location.basic_schedule_uuid)
    second_schedule.uuid.should eql(second_location.basic_schedule_uuid)
  end

  it "should record the fields from a BX record in a BasicSchedule object" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new.cif')
    BasicSchedule.first.atoc_code.should eql('LM')
  end

  it "should process a set of STP Overlay BS/BX/LO/LI/LT records in a CIF file" do
    expected_data_before = {:schedule=>{:insert=>23, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :tiploc=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_stp_overlay_part1.cif').should eql(expected_data_before)
    expected_locations_before = ["CREWE", "CREWSJN", "BTHLYJN", "ALSAGER", "KIDSGRV", "STOKEOT", "STOKOTJ", "STONE", "NTNB", "STAFFRD", "COLWICH", "RUGLYNJ", "RUGL", "LCHTNJ", "LCHTTVL", "TMWTHLL", "AMNGTNJ", "ATHRSTN", "NNTN", "RUGBTVJ", "RUGBY", "HMTNJ", "LNGBKBY", "NMPTN", "HANSLPJ", "MKNSCEN", "BLTCHLY", "LTNBZRD", "LEDBRNJ", "TRING", "BONENDJ", "WATFDJ", "HROW", "WMBY", "WLSDWLJ", "CMDNJN", "CMDNSTH", "EUSTON"]
    BasicSchedule.find_by_run_date('2011-05-08').locations.collect { |location| location.tiploc_code }.should eql(expected_locations_before)

    expected_data_after = {:schedule=>{:insert=>0, :delete=>1, :amend=>1}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :tiploc=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_stp_overlay_part2.cif').should eql(expected_data_after)
    expected_locations_after = ["CREWE", "CREWSJN", "BTHLYJN", "ALSAGER", "KIDSGRV", "STOKEOT", "STOKOTJ", "STONE", "NTNB", "STAFFRD", "COLWICH", "RUGLYNJ", "RUGL", "LCHTNJ", "LCHTTVL", "TMWTHLL", "AMNGTNJ", "ATHRSTN", "NNTN", "RUGBTVJ", "RUGBY", "HMTNJ", "WEEDON", "HANSLPJ", "MKNSCEN", "BLTCHLY", "LTNBZRD", "LEDBRNJ", "TRING", "BONENDJ", "WATFDJ", "HROW", "WMBY", "WLSDWLJ", "CMDNJN", "CMDNSTH", "EUSTON"]
    BasicSchedule.find_by_run_date('2011-05-08').locations.collect { |location| location.tiploc_code }.should eql(expected_locations_after)
  end

  it "shoud process a set of STP New Schedule BS/BX/LO/LI/LT records in a CIF file" do
    expected_data = {:schedule=>{:insert=>23, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :tiploc=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_stp_new_part1.cif').should eql(expected_data)
  end

  it "should process a schedule without LI records in a CIF file" do
    expected_data = {:schedule=>{:insert=>23, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :tiploc=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_process_lolt.cif').should eql(expected_data)    
  end

  it "should reject invalid BS record transaction types in a CIF file" do
    lambda { TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_invalid.cif') }.should raise_error
  end

  it "should handle train schedules which pass over midnight"

  it "should treat all times in the CIF file as the local timezone"

  it "should process delete BS records from a CIF file" do
    expected_data_before = {:schedule=>{:insert=>1, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :tiploc=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_delete_part1.cif').should eql(expected_data_before)
    expected_data_after = {:schedule=>{:insert=>0, :delete=>1, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :tiploc=>{:insert=>0, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_delete_part2.cif').should eql(expected_data_after)
  end

  it "should process revise BS records from a CIF file" do
    expected_data_before = {:association=>{:amend=>0, :insert=>0, :delete=>0}, :schedule=>{:amend=>0, :insert=>69, :delete=>0}, :tiploc=>{:amend=>0, :insert=>0, :delete=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/bs_revise_1.cif').should eql(expected_data_before)
    expected_data_after = {:association=>{:amend=>0, :insert=>0, :delete=>0}, :schedule=>{:amend=>69, :insert=>0, :delete=>69}, :tiploc=>{:amend=>0, :insert=>0, :delete=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/bs_revise_2.cif').should eql(expected_data_after)
  end


  # Miscellaneous functions

  it "should sort a list of Locations by their arrival, passing and departure times" do

    # Sort trains by passing time

    loc_p1 = Location.new(:tiploc_code => '1', :location_type => 'LI', :pass => '2011-01-01 12:00:00')
    loc_p2 = Location.new(:tiploc_code => '2', :location_type => 'LI', :pass => '2011-01-01 12:05:00')
    loc_p3 = Location.new(:tiploc_code => '3', :location_type => 'LI', :pass => '2011-01-01 12:10:00')

    [ loc_p3, loc_p1, loc_p2 ].sort { |a,b| TSDBExplorer::train_sort(a,b) }.should eql([ loc_p1, loc_p2, loc_p3 ])

    # Sort trains by departure time

    loc_d1 = Location.new(:tiploc_code => '1', :location_type => 'LO', :departure => '2011-01-01 12:01:00')
    loc_d2 = Location.new(:tiploc_code => '2', :location_type => 'LO', :departure => '2011-01-01 12:06:30')
    loc_d3 = Location.new(:tiploc_code => '3', :location_type => 'LO', :departure => '2011-01-01 12:11:00')

    [ loc_d3, loc_d1, loc_d2 ].sort { |a,b| TSDBExplorer::train_sort(a,b) }.should eql([ loc_d1, loc_d2, loc_d3 ])

    # Sort trains by arrival time

    loc_a1 = Location.new(:tiploc_code => '1', :location_type => 'LT', :arrival => '2011-01-01 12:02:00')
    loc_a2 = Location.new(:tiploc_code => '2', :location_type => 'LT', :arrival => '2011-01-01 12:07:30')
    loc_a3 = Location.new(:tiploc_code => '3', :location_type => 'LT', :arrival => '2011-01-01 12:12:00')

    [ loc_a3, loc_a1, loc_a2 ].sort { |a,b| TSDBExplorer::train_sort(a,b) }.should eql([ loc_a1, loc_a2, loc_a3 ])

    # Sort trains by all three

    [ loc_p1, loc_p2, loc_p3, loc_d1, loc_d2, loc_d3, loc_a1, loc_a2, loc_a3 ].sort { |a,b| TSDBExplorer::train_sort(a,b) }.should eql([ loc_p1, loc_d1, loc_a1, loc_p2, loc_d2, loc_a2, loc_p3, loc_d3, loc_a3 ])

    # Sort trains where one has an arrival and departure time, and the other has a departure time

    loc_ad1 = Location.new(:tiploc_code => '1', :location_type => 'LT', :arrival => '2011-01-01 12:02:00', :departure => '2011-01-01 12:08:00')
    loc_ad2 = Location.new(:tiploc_code => '2', :location_type => 'LT', :departure => '2011-01-01 12:07:30')

    [ loc_ad1, loc_ad2 ].sort { |a,b| TSDBExplorer::train_sort(a,b) }.should eql([ loc_ad2, loc_ad1 ])

    # Sort trains where both have an arrival and departure time, but one leaves before the other

    loc_ad1 = Location.new(:tiploc_code => '1', :location_type => 'LT', :arrival => '2011-01-01 12:02:00', :departure => '2011-01-01 12:08:00')
    loc_ad2 = Location.new(:tiploc_code => '2', :location_type => 'LT', :arrival => '2011-01-01 12:01:30', :departure => '2011-01-01 12:07:30')

    [ loc_ad1, loc_ad2 ].sort { |a,b| TSDBExplorer::train_sort(a,b) }.should eql([ loc_ad2, loc_ad1 ])

  end

end
