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

describe "lib/tsdbexplorer/tdnet.rb" do

  # Network Rail TD.net message parsing

  it "should parse a raw Train Describer CA message" do
    expected_data = { :message_type => 'CA', :td_identity => 'aa', :from_berth => 'bbbb', :to_berth => 'cccc', :train_description => 'dddd', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_message('<CA_MSG>aaCAbbbbccccddddeeeeee</CA_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer CB message" do
    expected_data = { :message_type => 'CB', :td_identity => 'aa', :from_berth => 'bbbb', :train_description => 'dddd', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_message('<CB_MSG>aaCBbbbbddddeeeeee</CB_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer CC message" do
    expected_data = { :message_type => 'CC', :td_identity => 'aa', :to_berth => 'cccc', :train_description => 'dddd', :timestamp => 'eeeeee'}
    TSDBExplorer::TDnet::parse_message('<CC_MSG>aaCCccccddddeeeeee</CC_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer CT message" do
    expected_data = { :message_type => 'CT', :td_identity => 'aa', :timestamp_four => 'hhmm', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_message('<CT_MSG>aaCThhmmeeeeee</CT_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer SF message" do
    expected_data = { :message_type => 'SF', :td_identity => 'aa', :address => 'ff', :data => 'gg', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_message('<SF_MSG>aaSFffggeeeeee</SF_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer SG message" do
    expected_data = { :message_type => 'SG', :td_identity => 'aa', :address => 'ff', :data => 'gggggggg', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_message('<SG_MSG>aaSGffggggggggeeeeee</SG_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer SH message" do
    expected_data = { :message_type => 'SH', :td_identity => 'aa', :address => 'ff', :data => 'gggggggg', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_message('<SH_MSG>aaSHffggggggggeeeeee</SH_MSG>').should eql(expected_data)
  end

  it "should raise an error if passed an invalid Train Describer message type" do
    lambda { TSDBExplorer::TDnet::parse_message('<ZZ_MSG>foobarbazqux</ZZ_MSG>') }.should raise_error
  end

  it "should parse a compact Train Describer CA message" do
    expected_data = { :message_type => 'CA', :td_identity => 'SU', :timestamp => '07:59:30Z', :from_berth => 'FROM', :to_berth => 'TOBH', :train_description => 'TDSC' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="CA" TDIdentity="SU" timestamp="07:59:30Z" fromBerthAddress="FROM" toBerthAddress="TOBH" trainIdentity="TDSC" />').should eql(expected_data)
  end

  it "should parse a compact Train Describer CB message" do
    expected_data = { :message_type => 'CB', :td_identity => 'SU', :timestamp => '07:59:30Z', :from_berth => 'FROM', :train_description => 'TDSC' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="CB" TDIdentity="SU" timestamp="07:59:30Z" fromBerthAddress="FROM" trainIdentity="TDSC" />').should eql(expected_data)
  end

  it "should parse a compact Train Describer CC message" do
    expected_data = { :message_type => 'CC', :td_identity => 'SU', :timestamp => '07:59:30Z', :to_berth => 'TOBH', :train_description => 'TDSC' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="CC" TDIdentity="SU" timestamp="07:59:30Z" toBerthAddress="TOBH" trainIdentity="TDSC" />').should eql(expected_data)
  end

  it "should parse a compact Train Describer CT message" do
    expected_data = { :message_type => 'CT', :td_identity => 'SU', :timestamp => '07:59:30Z', :timestamp_four => '0759' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="CT" TDIdentity="SU" timestamp="07:59:30Z" TDReportTime="0759" />').should eql(expected_data)
  end

  it "should parse a compact Train Describer SF message" do
    expected_data = { :message_type => 'SF', :td_identity => 'SU', :timestamp => '07:59:30Z', :address => '0C', :data => '66' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="SF" TDIdentity="SU" timestamp="07:59:30Z" equipmentStatusAddress="0C" equipmentStatus="66" />').should eql(expected_data)
  end

  it "should parse a compact Train Describer SG message" do
    expected_data = { :message_type => 'SG', :td_identity => 'SU', :timestamp => '07:59:30Z', :address => '0C', :data => '66666666' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="SG" TDIdentity="SU" timestamp="07:59:30Z" equipmentBaseScanAddress="0C" equipmentBaseScan="66666666" />').should eql(expected_data)
  end

  it "should parse a compact Train Describer SH message" do
    expected_data = { :message_type => 'SH', :td_identity => 'SU', :timestamp => '07:59:30Z', :address => '0C', :data => '66666666' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="SH" TDIdentity="SU" timestamp="07:59:30Z" equipmentBaseScanAddress="0C" equipmentBaseScan="66666666" />').should eql(expected_data)
  end


  # TRUST message data (raw)

  it "should process a TRUST Train Activation message" do
    data = "000120060208122136TRUST               TOPS                NETWORK9E00000001214567890200702081221060725720070208100000C126642005121200000020060609000000VP1M99M002300725720060208110000AN6522112001001"
    expected_data = { :message_type => '0001', :message_queue_timestamp => Time.parse('2006-02-08 12:21:36'), :source_system_id => 'TRUST', :original_data_source => 'TOPS', :user_id => 'NETWORK9', :source_dev_id => 'E0000000', :train_id => '1214567890', :train_creation_timestamp => Time.parse('2007-02-08 12:21:06'), :schedule_origin_stanox => '07257', :schedule_origin_depart_timestamp => Time.parse('2007-02-08 10:00:00'), :train_uid => 'C12664', :schedule_start_date => Time.parse('2005-12-12 00:00:00'), :schedule_end_date => Time.parse('2006-06-09 00:00:00'), :schedule_source => 'V', :schedule_type => 'P', :schedule_wtt_id => '1M99M', :d1266_record_number => '00230', :tp_origin_location => '07257', :tp_origin_timestamp => Time.parse('2006-02-08 11:00:00'), :train_call_type => 'A', :train_call_mode => 'N', :toc_id => '65', :train_service_code => '22112001', :train_file_address => '001' }
    TSDBExplorer::TDnet::parse_raw_message(data).should eql(expected_data)
  end

  it "should process a TRUST Train Cancellation message" do
    data = "000220110701065918TRUST               TRUST DA            #QHPA004LWED    522W10M601201107010659005274120110701063000     00000000000000C522W10M60121940001M52121C   "
    expected_data = { :message_type => '0002', :message_queue_timestamp => Time.parse('2011-07-01 06:59:18'), :source_system_id => 'TRUST', :original_data_source => 'TRUST DA', :user_id => '#QHPA004', :source_dev_id => 'LWED', :train_id => '522W10M601', :train_cancellation_timestamp => Time.parse('2011-07-01 06:59:00'), :location => '52741', :departure_timestamp => Time.parse('2011-07-01 06:30:00'), :original_location => nil, :original_location_timestamp => nil, :cancellation_type => 'C', :current_train_id => '522W10M601', :train_service_code => '21940001', :cancellation_reason_code => 'M5', :division_code => '21', :toc => '21', :variation_status => 'C', :train_file_address => nil }
    TSDBExplorer::TDnet::parse_raw_message(data).should eql(expected_data)
  end

  it "should process a TRUST Train Movement message" do
    data = "000320060105100109TRUST               SDR                 #CF1CV26VDVF    121456789020070104101525421402007010410152620060104101527     00000000000000TAM    AA01214567890223400007171000      000YY7JK42140Y"
    expected_data = { :message_type => '0003', :message_queue_timestamp => Time.parse('2006-01-05 10:01:09'), :source_system_id => 'TRUST', :original_data_source => 'SDR', :user_id => '#CF1CV26', :source_dev_id => 'VDVF', :train_id => '1214567890', :actual_timestamp => Time.parse('2007-01-04 10:15:25'), :location_stanox => '42140', :gbtt_event_timestamp => Time.parse('2007-01-04 10:15:26'), :planned_event_timestamp => Time.parse('2006-01-04 10:15:27'), :original_location => nil, :original_location_timestamp => nil, :planned_event_type => 'T', :event_type => 'A', :planned_event_source => 'M', :correction_indicator => nil, :offroute_indicator => nil, :direction_indicator => nil, :line_indicator => nil, :platform => 'AA', :route => '0', :current_train_id => '1214567890', :train_service_code => '22340000', :division_code => '71', :toc_id => '71', :timetable_variation => '000', :variation_status => nil, :next_report => nil, :next_report_run_time => '000', :train_terminated => 'Y', :delay_monitoring_point => 'Y', :train_file_address => '7JK', :reporting_stanox => '42140', :auto_expected => 'Y' }
    TSDBExplorer::TDnet::parse_raw_message(data).should eql(expected_data)
  end

  it "should process a TRUST Unidentified Train message" do
    data = "000420060105100109ABCDEFGHIJKLMNOPQMMMABCDEFGHIJKLMNOPQNNNAAAABBCCCCCCDDEE12342007030210152512345AUF12AA  "
    expected_data = { :message_type => '0004', :message_queue_timestamp => Time.parse('2006-01-05 10:01:09'), :source_system_id => 'ABCDEFGHIJKLMNOPQMMM', :original_data_source => 'ABCDEFGHIJKLMNOPQNNN', :user_id => 'AAAABBCC', :source_dev_id => 'CCCCDDEE', :wtt_id => '1234', :actual_timestamp => Time.parse('2007-03-02 10:15:25'), :location_stanox => '12345', :event_type => 'A', :direction_indicator => 'U', :line_indicator => 'F', :platform => '12', :route => 'A', :division_code => 'A ', :variation_status => nil }
    TSDBExplorer::TDnet::parse_raw_message(data).should eql(expected_data)
  end

  it "should process a TRUST Train Reinstatement message" do
    data = "000520060208160404TRUST               SDR                 #CF1CV26VDVF    1214567890200703061604004214020070306144800     00000000000000651F45MN08223000036671R899"
    expected_data = { :message_type => '0005', :message_queue_timestamp => Time.parse('2006-02-08 16:04:04'), :source_system_id => 'TRUST', :original_data_source => 'SDR', :user_id => '#CF1CV26', :source_dev_id => 'VDVF', :train_id => '1214567890', :reinstatement_timestamp => Time.parse('2007-03-06 16:04:00'), :location_stanox => '42140', :departure_timestamp => Time.parse('2007-03-06 14:48:00'), :original_location => nil, :original_location_timestamp => nil, :current_train_id => '651F45MN08', :train_service_code => '22300003', :division_code => '66', :toc_id => '71', :variation_status => 'R', :train_file_address => '899' }
    TSDBExplorer::TDnet::parse_raw_message(data).should eql(expected_data)
  end

  it "should process a TRUST Change of Origin message" do
    data = "000620060208162531TRUST               TRUST DA            #CF1CV26LUAM    1214567890200703021625006531120060302151800     20070302162500129456789922108001AA0671O8MV"
    expected_data = { :message_type => '0006', :message_queue_timestamp => Time.parse('2006-02-08 16:25:31'), :source_system_id => 'TRUST', :original_data_source => 'TRUST DA', :user_id => '#CF1CV26', :source_dev_id => 'LUAM', :train_id => '1214567890', :change_of_origin_timestamp => Time.parse('2007-03-02 16:25:00'), :location_stanox => '65311', :departure_timestamp => Time.parse('2006-03-02 15:18:00'), :original_location => nil, :original_location_timestamp => Time.parse('2007-03-02 16:25:00'), :current_train_id => '1294567899', :train_service_code => '22108001', :reason_code => 'AA', :division_code => '06', :toc_id => '71', :variation_status => 'O', :train_file_address => '8MV' }
    TSDBExplorer::TDnet::parse_raw_message(data).should eql(expected_data)
  end

  it "should process a TRUST Change of Identity message" do
    data = "000720060209060142TRUST               TOPS                        CY99996 121456789020070302152714422X112Q08422P182Q0822320003005"
    expected_data = { :message_type => '0007', :message_queue_timestamp => Time.parse('2006-02-09 06:01:42'), :source_system_id => 'TRUST', :original_data_source => 'TOPS', :user_id => nil, :source_dev_id => 'CY99996', :train_id => '1214567890', :event_timestamp => Time.parse('2007-03-02 15:27:14'), :revised_train_id => '422X112Q08', :current_train_id => '422P182Q08', :train_service_code => '22320003', :train_file_address => '005' }
    TSDBExplorer::TDnet::parse_raw_message(data).should eql(expected_data)
  end

  it "should process a TRUST Change of Location message" do
    data = "000820060105100109ABCDEFGHIJKLMNOPQMMMABCDEFGHIJKLMNOPQNNNAAAABBCCCCCCDDEE121456789020070302101525123452007030210152612345200601041015261214567890ABCDEFGHABC"
    expected_data = { :message_type => '0008', :message_queue_timestamp => Time.parse('2006-01-05 10:01:09'), :source_system_id => 'ABCDEFGHIJKLMNOPQMMM', :original_data_source => 'ABCDEFGHIJKLMNOPQNNN', :user_id => 'AAAABBCC', :source_dev_id => 'CCCCDDEE', :train_id => '1214567890', :event_timestamp => Time.parse('2007-03-02 10:15:25'), :revised_location => '12345', :planned_timestamp => Time.parse('2007-03-02 10:15:26'), :original_location => '12345', :original_timestamp => Time.parse('2006-01-04 10:15:26'), :current_train_id => '1214567890', :train_service_code => 'ABCDEFGH', :train_file_address => 'ABC' }
    TSDBExplorer::TDnet::parse_raw_message(data).should eql(expected_data)
  end


  # MQ Interface

  it "should receive a message from the TD_DATA queue and process it"
  it "should receive a message from the TR_DATA queue and process it"
  it "should receive a message from the VSTP_DATA queue and process it"
  it "should receive a message form the TSR_DATA queue and process it"


  # TRUST message handling

  it "should process a train activation message" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    TSDBExplorer::TDnet::process_trust_activation('C43391', '2010-12-12', '722N53MW12')
    ds = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
    ds.train_uid.should eql('C43391')
    ds.train_identity_unique.should eql('722N53MW12')
  end

  it "should not allow a train activation message for a date on which the schedule does not exist" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    TSDBExplorer::TDnet::process_trust_activation('C43391', '2010-12-13', '722N53MW13')
    ds = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-13').first
    ds.should be_nil
  end

  it "should not allow a train activation message for a date on which the schedule is cancelled" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_cancel.cif')
    TSDBExplorer::TDnet::process_trust_activation('C43391', '2011-01-19', '722N53MW19')
    ds = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-19').first
    ds.should be_nil
  end

  it "should handle a train activation message for an unknown train" do
    TSDBExplorer::TDnet::process_trust_activation('Z12345', '2011-01-01', '009Z99MA01')
    DailySchedule.all.count.should eql(0)
  end

  it "should process a train cancellation message" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    TSDBExplorer::TDnet::process_trust_activation('C43391', '2010-12-12', '722N53MW12')
    TSDBExplorer::TDnet::process_trust_cancellation('722N53MW12', Time.parse('2010-12-12 18:15:00'), 'M4')
    ds = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
    ds.cancelled?.should be_true
    ds.cancellation_timestamp.should eql(Time.parse('2010-12-12 18:15:00'))
    ds.cancellation_reason.should eql('M4')
  end

  it "should process a train movement message"
  it "should process an unidentified train report"
  it "should process a train reinstatement report"
  it "should process a train change-of-origin report"
  it "should process a train change-of-identity report"
  it "should process a train change-of-location report"

end
