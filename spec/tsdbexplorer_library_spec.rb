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

  it "should convert a date in YYMMDD format to YYYY-MM-DD" do

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

end
