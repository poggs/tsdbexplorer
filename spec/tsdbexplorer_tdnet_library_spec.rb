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

  # Network Rail SMART message parsing

  it "should parse a raw Train Describer CA message" do
    expected_data = { :message_type => 'CA', :td_identity => 'aa', :from_berth => 'bbbb', :to_berth => 'cccc', :train_description => 'dddd', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_smart_message('<CA_MSG>aaCAbbbbccccddddeeeeee</CA_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer CB message" do
    expected_data = { :message_type => 'CB', :td_identity => 'aa', :from_berth => 'bbbb', :train_description => 'dddd', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_smart_message('<CB_MSG>aaCBbbbbddddeeeeee</CB_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer CC message" do
    expected_data = { :message_type => 'CC', :td_identity => 'aa', :to_berth => 'cccc', :train_description => 'dddd', :timestamp => 'eeeeee'}
    TSDBExplorer::TDnet::parse_smart_message('<CC_MSG>aaCCccccddddeeeeee</CC_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer CT message" do
    expected_data = { :message_type => 'CT', :td_identity => 'aa', :timestamp_four => 'hhmm', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_smart_message('<CT_MSG>aaCThhmmeeeeee</CT_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer SF message" do
    expected_data = { :message_type => 'SF', :td_identity => 'aa', :address => 'ff', :data => 'gg', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_smart_message('<SF_MSG>aaSFffggeeeeee</SF_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer SG message" do
    expected_data = { :message_type => 'SG', :td_identity => 'aa', :address => 'ff', :data => 'gggggggg', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_smart_message('<SG_MSG>aaSGffggggggggeeeeee</SG_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer SH message" do
    expected_data = { :message_type => 'SH', :td_identity => 'aa', :address => 'ff', :data => 'gggggggg', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_smart_message('<SH_MSG>aaSHffggggggggeeeeee</SH_MSG>').should eql(expected_data)
  end

  it "should raise an error if passed an invalid Train Describer message type" do
    lambda { TSDBExplorer::TDnet::parse_smart_message('<ZZ_MSG>foobarbazqux</ZZ_MSG>') }.should raise_error
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


  # TRUST message handling

  it "should process a train activation message" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    activation = TSDBExplorer::TDnet::process_trust_activation('C43391', '2010-12-12', '722N53MW12')
    activation.status.should eql(:ok)
    activation.message.should match(/C43391/)
    activation.message.should match(/722N53MW12/)
    ds = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
    ds.train_uid.should eql('C43391')
    ds.train_identity_unique.should eql('722N53MW12')
    ds.locations.count.should eql(18)
    first_location_data = { :location_type => "LO", :activity_tb => true, :tiploc_code => "EUSTON", :tiploc_instance => nil, :arrival => nil, :public_arrival => nil, :expected_arrival => nil, :actual_arrival => nil, :platform => '10', :actual_platform => nil, :line => 'C', :actual_line => nil, :pass => nil, :expected_pass => nil, :actual_pass => nil, :path => nil, :departure => Time.parse('2010-12-12 18:34:00'), :public_departure => Time.parse('2010-12-12 18:34:00'), :expected_departure => nil, :actual_departure => nil, :engineering_allowance => nil, :pathing_allowance => nil, :performance_allowance => nil, :cancelled => nil, :cancellation_reason => nil, :cancellation_timestamp => nil }
    first_location = ds.locations.first
    first_location_data.each do |k,v|
      first_location.send(k.to_sym).should eql(v)
    end
  end

  it "should not allow a train activation message for a date on which the schedule does not exist" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    activation = TSDBExplorer::TDnet::process_trust_activation('C43391', '2010-12-13', '722N53MW13')
    activation.status.should eql(:error)
    activation.message.should match(/C43391/)
    ds = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-13').first
    ds.should be_nil
  end

  it "should not allow a train activation message for a date on which the schedule is cancelled" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_cancel.cif')
    activation = TSDBExplorer::TDnet::process_trust_activation('C43391', '2011-01-19', '722N53MW19')
    activation.status.should eql(:error)
    activation.message.should match(/C43391/)
    ds = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-19').first
    ds.should be_nil
  end

  it "should handle a train activation message for an unknown train" do
    activation = TSDBExplorer::TDnet::process_trust_activation('Z12345', '2011-01-01', '009Z99MA01')
    activation.status.should eql(:error)
    activation.message.should match(/Z12345/)
    DailySchedule.all.count.should eql(0)
  end

  it "should process a train cancellation message" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    activation = TSDBExplorer::TDnet::process_trust_activation('C43391', '2010-12-12', '722N53MW12')
    activation.status.should eql(:ok)
    cancellation = TSDBExplorer::TDnet::process_trust_cancellation('722N53MW12', Time.parse('2010-12-12 18:15:00'), 'M4')
    cancellation.status.should eql(:ok)
    cancellation.message.should match(/722N53MW12/)
    cancellation.message.should match(/M4/)
    ds = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
    ds.cancelled?.should be_true
    ds.cancellation_timestamp.should eql(Time.parse('2010-12-12 18:15:00'))
    ds.cancellation_reason.should eql('M4')
  end

  it "should not allow a train cancellation for a train which has not been activated" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    cancellation = TSDBExplorer::TDnet::process_trust_cancellation('722N53MW12', Time.parse('2010-12-12 18:15:00'), 'M4')
    cancellation.status.should eql(:error)
    cancellation.message.should match(/722N53MW12/)
    ds = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
    ds.should be_nil
  end

  it "should process a train movement message for a departure from an the originating station" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    activation = TSDBExplorer::TDnet::process_trust_message('000120101212161531TRUST               TSIA                                722N53MW12201012121615315222620101212183400C433912016071100000020160711000000CP2N53M000005222620101212183400AN3022214000   ')
    activation.status.should eql(:ok)
    movement = TSDBExplorer::TDnet::process_trust_message('000320101212183424TRUST               SMART                               722N53MW1220101212183400724102010121218340020101212183400     00000000000000DDA  U  23722N53MW26222140003030000 52219001 Y   72410Y')
    movement.status.should eql(:ok)
    movement.message.should match(/722N53MW12/)
    movement.message.should match(/LONDON EUSTON/)
    schedule = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
    originating_point = schedule.locations.find_by_tiploc_code('EUSTON')
    originating_point.actual_departure.should eql(DateTime.parse('2010-12-12 18:34:00'))
    originating_point.platform.should eql('10')
    originating_point.line.should eql('C')
  end

  it "should process a train movement message for a passing point" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    activation = TSDBExplorer::TDnet::process_trust_message('000120101212161531TRUST               TSIA                                722N53MW12201012121615315222620101212183400C433912016071100000020160711000000CP2N53M000005222620101212183400AN3022214000   ')
    activation.status.should eql(:ok)
    movement_1 = TSDBExplorer::TDnet::process_trust_message('000320101212183617TRUST               SMART                               722N53MW1220101212183600723160000000000000020101212183700     00000000000000DDA  DC  1722N53MX12222090002929001E72315000     00000Y')
    movement_1.status.should eql(:ok)
    movement_1.message.should match(/722N53MW12/)
    movement_1.message.should match(/CAMDEN SOUTH JN/)
    schedule = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
    passing_point = schedule.locations.find_by_tiploc_code('CMDNSTH')
    passing_point.actual_pass.should eql(Time.parse('2010-12-12 18:36:00'))
    passing_point.platform.should eql(nil)
    passing_point.line.should eql(nil)
  end

  it "should process a train movement message for a calling point" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    activation = TSDBExplorer::TDnet::process_trust_activation('C43391', '2010-12-12', '722N53MW12')
    activation.status.should eql(:ok)
    movement_1 = TSDBExplorer::TDnet::process_trust_message('000320101212184913TRUST               SMART                               722N53MW1220101212184900710402010121218500020101212185000     00000000000000AAA  D  80722N53MW12222090002929001E71011002 Y   71040Y')
    movement_1.status.should eql(:ok)
    movement_1.message.should match(/722N53MW12/)
    movement_1.message.should match(/WATFORD JUNCTION/)
    schedule = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
    calling_point_arrival = schedule.locations.find_by_tiploc_code('WATFDJ')
    calling_point_arrival.actual_arrival.should eql(Time.parse('2010-12-12 18:49:00'))
    movement_2 = TSDBExplorer::TDnet::process_trust_message('000320101212185122TRUST               SMART                               722N53MW1220101212185100710402010121218510020101212185100     00000000000000DDA  DS 82722N53MW12222090002929000 71011007 Y   71040Y')
    movement_2.status.should eql(:ok)
    movement_2.message.should match(/722N53MW12/)
    movement_2.message.should match(/WATFORD JUNCTION/)
    schedule = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
    calling_point_departure = schedule.locations.find_by_tiploc_code('WATFDJ')
    calling_point_departure.actual_departure.should eql(Time.parse('2010-12-12 18:51:00'))
  end

  it "should record the source of an automatically generated movement correctly"

  it "should record the source of a manually input movement correctly" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/abbey_line.cif')
    activation = TSDBExplorer::TDnet::process_trust_activation('P45779', '2011-07-17', '712F02MC17')
    activation.status.should eql(:ok)
    depart_saa_manual = TSDBExplorer::TDnet::process_trust_message('000320110718003245TRUST               SDR                 #QRP3750V3HK    712F02MC1720110717082800710302011071708280020110717082800     00000000000000DDM       712F02MC17222130002929000 71032003 Y   71030N')
    depart_saa_location = DailySchedule.runs_on_by_uid_and_date('P45779', '2011-07-17').first.locations.where(:tiploc_code => 'STALBNA').first
    depart_saa_location.event_source.should eql('M')
    arrive_wfj_manual = TSDBExplorer::TDnet::process_trust_message('000320110718003330TRUST               SDR                 #QRP3750V3HK    712F02MC1720110717084400710402011071708440020110717084400     00000000000000TAM      0712F02MC17222130002929000      000YY   71040Y')
    arrive_wfj_location = DailySchedule.runs_on_by_uid_and_date('P45779', '2011-07-17').first.locations.where(:tiploc_code => 'WATFDJ').first
    arrive_wfj_location.event_source.should eql('M')
  end

  it "should handle an off-route movement for a train"

  it "should process a train movement message for an arrival at the terminating station and set the Terminated flag" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    activation = TSDBExplorer::TDnet::process_trust_activation('C43391', '2010-12-12', '722N53MW12')
    activation.status.should eql(:ok)
    movement = TSDBExplorer::TDnet::process_trust_message('000320101212194309TRUST               SMART                               722N53MW1220101212194400701002010121219460020101212194600     00000000000000TAA  D3 30722N53MW12222090002929002E     000YY   70100Y')
    movement.status.should eql(:ok)
    schedule = DailySchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
    schedule.terminated?.should be_true
    terminating_point_arrival = schedule.locations.find_by_tiploc_code('NMPTN')
    terminating_point_arrival.actual_arrival.should eql(Time.parse('2010-12-12 19:44:00'))
  end

  it "should process a train movement message when the STANOX code identifies more than one TIPLOC" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_nonunique_stanox.cif')
    activation = TSDBExplorer::TDnet::process_trust_message('000120110522093221TRUST               TSIA                                521N08MH22201105220932215274120110522103200L029232017071100000020170711000000CP1N08M000005274120110522103200AN2121939001   ')
    activation.status.should eql(:ok)
    movement = TSDBExplorer::TDnet::process_trust_message('000320110522104541TRUST               SMART                               521N08MH2220110522104500504230000000000000020110522104330     00000000000000AAA      0521N08MH17219390012121002L50334001 Y   50423Y')
    movement.status.should eql(:ok)
    schedule = DailySchedule.runs_on_by_uid_and_date('L02923', '2011-05-22').first
    multi_tiploc_point = schedule.locations.find_by_tiploc_code('ILFORD')
    multi_tiploc_point.actual_pass.should eql(Time.parse('2011-05-22 10:45:00'))
  end

  it "should process an unidentified train report"

  it "should process a train reinstatement report" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/trust_cancellation_schedule.cif')

    activation = TSDBExplorer::TDnet::process_trust_message('000120110720160618TRUST               TSIA                                522Y01MW20201107201606175222620110720180600L951262023051100000020091211000000CO2Y01M000005222620110720180600AN3022214000   ')
    activation.status.should eql(:ok)
    activation.message.should include('Activated train UID L95126 on 2011-07-20 as train identity 522Y01MW20')

    cancellation = TSDBExplorer::TDnet::process_trust_message('000220110720181920TRUST               TRUST DA            #QHPA017LMWB    522Y01MW20201107201819005222620110720180600     00000000000000C522Y01MW2022214000M53030C   ')
    cancellation.status.should eql(:ok)
    cancellation.message.should include('Cancelled train 522Y01MW20 due to reason M5')

    cancelled_schedule = DailySchedule.runs_on_by_uid_and_date('L95126', '2011-07-20').first
    cancelled_schedule.cancelled?.should be_true
    cancelled_schedule.cancellation_reason.should eql('M5')

    reinstatement = TSDBExplorer::TDnet::process_trust_message('000520110720182503TRUST               TRUST DA            #QHPA017LMWB    522Y01MW20201107201825005222620110720180600     00000000000000522Y01MW20222140003030R   ')
    reinstatement.status.should eql(:ok)
    reinstatement.message.should include('Reinstated train 522Y01MW20')

    reinstated_schedule = DailySchedule.runs_on_by_uid_and_date('L95126', '2011-07-20').first
    reinstated_schedule.cancelled?.should_not be_true
    reinstated_schedule.cancellation_reason.should be_nil

    change_of_origin = TSDBExplorer::TDnet::process_trust_message('000620110720182519TRUST               TRUST DA                    LMWB    522Y01MW20201107201825007227520110720184730                   522Y01MW2022214000M53030O   ')
    change_of_origin.status.should eql(:ok)
    change_of_origin.message.should include('Changed origin of train 522Y01MW20 to')
    change_of_origin.message.should include('for reason M5')

    amended_schedule = DailySchedule.runs_on_by_uid_and_date('L95126', '2011-07-20').first
    amended_schedule.cancelled?.should_not be_true
    amended_schedule.cancellation_reason.should be_nil

    cancelled_locations = ["STFD", "CHNELSJ", "LEAJ", "HACKNYW", "HOMRTON", "HACKNYC", "NAVRDJ", "DALSKLD", "CNNB", "CNNBYWJ", "HIGHBYA", "WSBRNRJ", "CLDNNRB", "CMDNREJ", "CMDNRD", "CMDNRDJ", "KNTSHTW", "GOSPLOK", "HMPSTDH", "FNCHLYR", "WHMDSTD", "BRBY", "BRBYPK", "KENR", "KENSLGJ"]
    amended_schedule.locations.each do |loc|
      if cancelled_locations.include? loc.tiploc_code
        loc.cancelled.should be_true
        loc.cancellation_reason.should eql('M5')
      else
        loc.cancelled.should_not be_true
        loc.cancellation_reason.should be_nil
      end
    end

  end

  it "should process a train change-of-origin report" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/trust_coo_schedule.cif')

    activation = TSDBExplorer::TDnet::process_trust_message('000120110723163915TRUST               TSIA                                512O03MX23201107231639155170220110723183900L059852028051100000020101211000000CO2O03M000005170220110723183900AN2121920000   ')
    activation.status.should eql(:ok)
    activation.message.should include('Activated train UID L05985 on 2011-07-23')

    coo_broxbourne = TSDBExplorer::TDnet::process_trust_message('000620110723185333TRUST               TRUST DA                    LSHH    512O03MX23201107231853005172220110723185430                   512O03MX2321920000XR2121O   ')
    train_2O03 = DailySchedule.runs_on_by_uid_and_date('L05985', '2011-07-23').first

    cancelled_locations = ["HERTFDE", "WARE", "SMARGRT", "RYEHOUS", "BROXBNJ"]
    cancelled_locations.each do |l|
      loc = train_2O03.locations.where(:tiploc_code => l).first
      loc.cancelled.should be_true
      loc.cancellation_reason.should eql('XR')
    end

    running_locations = ["CHESHNT", "WALHAMX", "ENFLDLK", "BRIMSDN", "PNDRSEN", "TTNHMHL", "TTNHMSJ", "COPRMLJ", "CLAPTNJ", "HAKNYNM", "BTHNLGR", "LIVST"]
    running_locations.each do |l|
      loc = train_2O03.locations.where(:tiploc_code => l).first
      loc.cancelled.should_not be_true
      loc.cancellation_reason.should be_nil
    end

  end

  it "should return an error when processing a change-of-origin report for an unactivated train" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/trust_coo_schedule.cif')

    coo_unactivated_train = TSDBExplorer::TDnet::process_trust_message('000620110723185333TRUST               TRUST DA                    LSHH    512O03MX23201107231853005172220110723185430                   512O03MX2321920000XR2121O   ')

    coo_unactivated_train.status.should eql(:error)
    coo_unactivated_train.message.should include('COO message for unactivated train 512O03MX23')    

  end

  it "should return an error when processing a change-of-origin report for a train to an unknown location" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/trust_coo_schedule.cif')

    activation = TSDBExplorer::TDnet::process_trust_message('000120110723163915TRUST               TSIA                                512O03MX23201107231639155170220110723183900L059852028051100000020101211000000CO2O03M000005170220110723183900AN2121920000   ')
    coo_unknown_stanox = TSDBExplorer::TDnet::process_trust_message('000620110723185333TRUST               TRUST DA                    LSHH    512O03MX23201107231853009999920110723185430                   512O03MX2321920000XR2121O   ')

    coo_unknown_stanox.status.should eql(:error)
    coo_unknown_stanox.message.should include('COO message for train 512O03MX23')
    coo_unknown_stanox.message.should include('unknown STANOX 99999')

  end

  it "should return an error when processing a change-of-origin report for a train to a location not in the schedule" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/trust_coo_schedule.cif')

    activation = TSDBExplorer::TDnet::process_trust_message('000120110723163915TRUST               TSIA                                512O03MX23201107231639155170220110723183900L059852028051100000020101211000000CO2O03M000005170220110723183900AN2121920000   ')
    coo_nonschedule_stanox = TSDBExplorer::TDnet::process_trust_message('000620110723185333TRUST               TRUST DA                    LSHH    512O03MX23201107231853001713220110723185430                   512O03MX2321920000XR2121O   ')

    coo_nonschedule_stanox.status.should eql(:error)
    coo_nonschedule_stanox.message.should include('COO message for train 512O03MX23')
    coo_nonschedule_stanox.message.should include('changes origin to LEEDS which is not in the schedule')

  end

  it "should process a train change-of-identity report"
  it "should process a train change-of-location report"


  # Real-time data processing

  it "should allow a train to be activated and record its progress" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/tdnet/train_movement_1_schedule.cif')

    activation = TSDBExplorer::TDnet::process_trust_message('000120110824230314TRUST               TSIA                                522T52M125201108242303145274120110825010300L068092024051100000020101211000000CO2T52M000005274120110825010300AN2121910000   ')
    activation.status.should eql(:ok)
    activation.message.should include('Activated train UID L06809 on 2011-08-25 as train identity 522T52M125')
    DailySchedule.count.should eql(1)
    first_schedule = DailySchedule.first
    first_schedule_expected = { :runs_on => Date.parse('2011-08-25'), :cancelled => nil, :cancellation_timestamp => nil, :cancellation_reason => nil, :status => "P", :train_uid => "L06809", :category => "OO", :train_identity => "2T52", :train_identity_unique => "522T52M125", :headcode => nil, :service_code => "21910000", :portion_id => nil, :power_type => "EMU", :timing_load => "317", :speed => "100", :operating_characteristics => "D", :train_class => "S", :sleepers => nil, :reservations => nil, :catering_code => nil, :service_branding => nil, :stp_indicator => "P", :uic_code => nil, :atoc_code => "LE", :ats_code => "Y", :rsid => nil, :data_source => nil }
    first_schedule_expected.each do |k,v|
      first_schedule.send(k.to_sym).should eql(v)
    end
    first_schedule.departed_origin?.should_not be_true
    first_schedule.terminated?.should_not be_true
    DailySchedule.first.locations.count.should eql(10)

    depart_liverpool_street = TSDBExplorer::TDnet::process_trust_message('000320110825010359TRUST               SMART                               522T52M12520110825010300527412011082501030020110825010300     00000000000000DDA  DS 31522T52M125219100002121000 52739003 Y   52741Y')
    depart_liverpool_street.status.should eql(:ok)
    depart_liverpool_street.message.should include('Processed movement type D for train 522T52M125 at LONDON LIVERPOOL STREET')
    depart_liverpool_street_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    depart_liverpool_street_rec.departed_origin?.should be_true
    depart_liverpool_street_rec.terminated?.should_not be_true
    depart_liverpool_street_rec.locations[0].actual_arrival.should be_nil
    depart_liverpool_street_rec.locations[0].actual_pass.should be_nil
    depart_liverpool_street_rec.locations[0].actual_departure.should eql(DateTime.parse('2011-08-25 00:03:00'))
    depart_liverpool_street_rec.locations[0].actual_platform.should eql('3')
    depart_liverpool_street_rec.locations[0].actual_line.should eql('S')
    depart_liverpool_street_rec.locations[0].actual_path.should be_nil

    arrive_bethnal_green = TSDBExplorer::TDnet::process_trust_message('000320110825010617TRUST               SMART                               522T52M12520110825010600527390000000000000020110825010600     00000000000000AAA      0522T52M125219100002121000 52736001 Y   52739Y')
    arrive_bethnal_green.status.should eql(:ok)
    arrive_bethnal_green.message.should include('Processed movement type A for train 522T52M125 at BETHNAL GREEN')
    arrive_bethnal_green_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    arrive_bethnal_green_rec.terminated?.should_not be_true
    arrive_bethnal_green_rec.departed_origin?.should be_true
    arrive_bethnal_green_rec.locations[1].actual_arrival.should be_nil
    arrive_bethnal_green_rec.locations[1].actual_pass.should eql(DateTime.parse('2011-08-25 00:06:00'))
    arrive_bethnal_green_rec.locations[1].actual_departure.should be_nil
    arrive_bethnal_green_rec.locations[1].actual_platform.should be_nil
    arrive_bethnal_green_rec.locations[1].actual_line.should be_nil
    arrive_bethnal_green_rec.locations[1].actual_path.should be_nil

    depart_bethnal_green = TSDBExplorer::TDnet::process_trust_message('000320110825010641TRUST               SMART                               522T52M12520110825010600527390000000000000020110825010600     00000000000000DDA  DS  1522T52M125219100002121000 52736004 Y   52739Y')
    depart_bethnal_green.status.should eql(:ok)
    depart_bethnal_green.message.should include('Processed movement type D for train 522T52M125 at BETHNAL GREEN')
    depart_bethnal_green_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    depart_bethnal_green_rec.departed_origin?.should be_true
    depart_bethnal_green_rec.terminated?.should_not be_true
    depart_bethnal_green_rec.locations[1].actual_arrival.should be_nil
    depart_bethnal_green_rec.locations[1].actual_pass.should eql(DateTime.parse('2011-08-25 00:06:00'))
    depart_bethnal_green_rec.locations[1].actual_departure.should be_nil
    depart_bethnal_green_rec.locations[1].actual_platform.should be_nil
    depart_bethnal_green_rec.locations[1].actual_line.should eql('S')
    depart_bethnal_green_rec.locations[1].actual_path.should be_nil

    arrive_hackney_downs = TSDBExplorer::TDnet::process_trust_message('000320110825010925TRUST               SMART                               522T52M12520110825011000527362011082501100020110825011000     00000000000000AAA  D  40522T52M125219100002121000 52735001 Y   52736Y')
    arrive_hackney_downs.status.should eql(:ok)
    arrive_hackney_downs.message.should include('Processed movement type A for train 522T52M125 at HACKNEY DOWNS')
    arrive_hackney_downs_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    arrive_hackney_downs_rec.departed_origin?.should be_true
    arrive_hackney_downs_rec.terminated?.should_not be_true
    arrive_hackney_downs_rec.locations[2].actual_arrival.should eql(DateTime.parse('2011-08-25 00:10:00'))
    arrive_hackney_downs_rec.locations[2].actual_pass.should be_nil
    arrive_hackney_downs_rec.locations[2].actual_departure.should be_nil
    arrive_hackney_downs_rec.locations[2].actual_platform.should eql('4')
    arrive_hackney_downs_rec.locations[2].actual_line.should be_nil
    arrive_hackney_downs_rec.locations[2].actual_path.should be_nil

    depart_hackney_downs = TSDBExplorer::TDnet::process_trust_message('000320110825011100TRUST               SMART                               522T52M12520110825011000527362011082501100020110825011030     00000000000000DDA  D   1522T52M125219100002121000 52735003 Y   52736Y')
    depart_hackney_downs.status.should eql(:ok)
    depart_hackney_downs.message.should include('Processed movement type D for train 522T52M125 at HACKNEY DOWNS')
    depart_hackney_downs_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    depart_hackney_downs_rec.departed_origin?.should be_true
    depart_hackney_downs_rec.terminated?.should_not be_true
    depart_hackney_downs_rec.locations[2].actual_arrival.should eql(DateTime.parse('2011-08-25 00:10:00'))
    depart_hackney_downs_rec.locations[2].actual_pass.should be_nil
    depart_hackney_downs_rec.locations[2].actual_departure.should eql(DateTime.parse('2011-08-25 00:10:00'))
    depart_hackney_downs_rec.locations[2].actual_platform.should eql('4')
    depart_hackney_downs_rec.locations[2].actual_line.should be_nil
    depart_hackney_downs_rec.locations[2].actual_path.should be_nil

    arrive_clapton = TSDBExplorer::TDnet::process_trust_message('000320110825011302TRUST               SMART                               522T52M12520110825011300527352011082501130020110825011300     00000000000000AAA  D   0522T52M125219100002121000 51938001     00000Y')
    arrive_clapton.status.should eql(:ok)
    arrive_clapton.message.should include('Processed movement type A for train 522T52M125 at CLAPTON')
    arrive_clapton_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    arrive_clapton_rec.departed_origin?.should be_true
    arrive_clapton_rec.terminated?.should_not be_true
    arrive_clapton_rec.locations[3].actual_arrival.should eql(DateTime.parse('2011-08-25 00:13:00'))
    arrive_clapton_rec.locations[3].actual_pass.should be_nil
    arrive_clapton_rec.locations[3].actual_departure.should be_nil
    arrive_clapton_rec.locations[3].actual_platform.should be_nil
    arrive_clapton_rec.locations[3].actual_line.should be_nil
    arrive_clapton_rec.locations[3].actual_path.should be_nil

    depart_clapton = TSDBExplorer::TDnet::process_trust_message('000320110825011419TRUST               SMART                               522T52M12520110825011400527352011082501130020110825011330     00000000000000DDA  D   1522T52M125219100002121001L51938001     00000Y')
    depart_clapton.status.should eql(:ok)
    depart_clapton.message.should include('Processed movement type D for train 522T52M125 at CLAPTON')
    depart_clapton_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    depart_clapton_rec.departed_origin?.should be_true
    depart_clapton_rec.terminated?.should_not be_true
    depart_clapton_rec.locations[3].actual_arrival.should eql(DateTime.parse('2011-08-25 00:13:00'))
    depart_clapton_rec.locations[3].actual_pass.should be_nil
    depart_clapton_rec.locations[3].actual_departure.should eql(DateTime.parse('2011-08-25 00:14:00'))
    depart_clapton_rec.locations[3].actual_platform.should be_nil
    depart_clapton_rec.locations[3].actual_line.should be_nil
    depart_clapton_rec.locations[3].actual_path.should be_nil

    # NOTE: No TRUST message for Clapton Junction pass received

    arrive_st_james_street_cp = TSDBExplorer::TDnet::process_trust_message('000320110825011656TRUST               SMART                               522T52M12520110825011700527342011082501170020110825011630     00000000000000AAA  D   0522T52M125219100002121001L52733001     00000Y')
    arrive_st_james_street_cp.status.should eql(:ok)
    arrive_st_james_street_cp.message.should include('Processed movement type A for train 522T52M125 at ST JAMES STREET')
    arrive_st_james_street_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    arrive_st_james_street_rec.departed_origin?.should be_true
    arrive_st_james_street_rec.terminated?.should_not be_true
    arrive_st_james_street_rec.locations[5].actual_arrival.should eql(DateTime.parse('2011-08-25 00:17:00'))
    arrive_st_james_street_rec.locations[5].actual_pass.should be_nil
    arrive_st_james_street_rec.locations[5].actual_departure.should be_nil
    arrive_st_james_street_rec.locations[5].actual_platform.should be_nil
    arrive_st_james_street_rec.locations[5].actual_line.should be_nil
    arrive_st_james_street_rec.locations[5].actual_path.should be_nil

    # NOTE: No TRUST message for St James Street departure received

    arrive_walthamstow_central_cp = TSDBExplorer::TDnet::process_trust_message('000320110825011845TRUST               SMART                               522T52M12520110825011900527332011082501190020110825011830     00000000000000AAA  D   0522T52M125219100002121001L52729001 Y   52733Y')
    arrive_walthamstow_central_cp.status.should eql(:ok)
    arrive_walthamstow_central_cp.message.should include('Processed movement type A for train 522T52M125 at WALTHAMSTOW CENTRAL')
    arrive_walthamstow_central_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    arrive_walthamstow_central_rec.locations[6].actual_arrival.should eql(DateTime.parse('2011-08-25 00:19:00'))
    arrive_walthamstow_central_rec.departed_origin?.should be_true
    arrive_walthamstow_central_rec.terminated?.should_not be_true
    arrive_walthamstow_central_rec.locations[6].actual_pass.should be_nil
    arrive_walthamstow_central_rec.locations[6].actual_departure.should be_nil
    arrive_walthamstow_central_rec.locations[6].actual_platform.should be_nil
    arrive_walthamstow_central_rec.locations[6].actual_line.should be_nil
    arrive_walthamstow_central_rec.locations[6].actual_path.should be_nil

    depart_walthamstow_central_cp = TSDBExplorer::TDnet::process_trust_message('000320110825012018TRUST               SMART                               522T52M12520110825012000527332011082501190020110825011900     00000000000000DDA  D   2522T52M125219100002121001L52729001 Y   52733Y')
    depart_walthamstow_central_cp.status.should eql(:ok)
    depart_walthamstow_central_cp.message.should include('Processed movement type D for train 522T52M125 at WALTHAMSTOW CENTRAL')
    depart_walthamstow_central_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    depart_walthamstow_central_rec.departed_origin?.should be_true
    depart_walthamstow_central_rec.terminated?.should_not be_true
    depart_walthamstow_central_rec.locations[6].actual_arrival.should eql(DateTime.parse('2011-08-25 00:19:00'))
    depart_walthamstow_central_rec.locations[6].actual_pass.should be_nil
    depart_walthamstow_central_rec.locations[6].actual_departure.should eql(DateTime.parse('2011-08-25 00:20:00'))
    depart_walthamstow_central_rec.locations[6].actual_platform.should be_nil
    depart_walthamstow_central_rec.locations[6].actual_line.should be_nil
    depart_walthamstow_central_rec.locations[6].actual_path.should be_nil

    arrive_wood_street_cp = TSDBExplorer::TDnet::process_trust_message('000320110825012153TRUST               SMART                               522T52M12520110825012200527292011082501210020110825012030     00000000000000AAA  D   0522T52M125219100002121002L52732001     00000Y')
    arrive_wood_street_cp.status.should eql(:ok)
    arrive_wood_street_cp.message.should include('Processed movement type A for train 522T52M125 at WOOD STREET')
    arrive_wood_street_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    arrive_wood_street_rec.departed_origin?.should be_true
    arrive_wood_street_rec.terminated?.should_not be_true
    arrive_wood_street_rec.locations[7].actual_arrival.should eql(DateTime.parse('2011-08-25 00:22:00'))
    arrive_wood_street_rec.locations[7].actual_pass.should be_nil
    arrive_wood_street_rec.locations[7].actual_departure.should be_nil
    arrive_wood_street_rec.locations[7].actual_platform.should be_nil
    arrive_wood_street_rec.locations[7].actual_line.should be_nil
    arrive_wood_street_rec.locations[7].actual_path.should be_nil

    depart_wood_street_cp = TSDBExplorer::TDnet::process_trust_message('000320110825012317TRUST               SMART                               522T52M12520110825012200527292011082501210020110825012100     00000000000000DDA  D   1522T52M125219100002121001L52732002     00000Y')
    depart_wood_street_cp.status.should eql(:ok)
    depart_wood_street_cp.message.should include('Processed movement type D for train 522T52M125 at WOOD STREET')
    depart_wood_street_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    depart_wood_street_rec.departed_origin?.should be_true
    depart_wood_street_rec.terminated?.should_not be_true
    depart_wood_street_rec.locations[7].actual_arrival.should eql(DateTime.parse('2011-08-25 00:22:00'))
    depart_wood_street_rec.locations[7].actual_pass.should be_nil
    depart_wood_street_rec.locations[7].actual_departure.should eql(DateTime.parse('2011-08-25 00:22:00'))
    depart_wood_street_rec.locations[7].actual_platform.should be_nil
    depart_wood_street_rec.locations[7].actual_line.should be_nil
    depart_wood_street_rec.locations[7].actual_path.should be_nil

    arrive_highams_park_cp = TSDBExplorer::TDnet::process_trust_message('000320110825012513TRUST               SMART                               522T52M12520110825012500527322011082501240020110825012330     00000000000000AAA  D   0522T52M125219100002121002L52731001     00000Y')
    arrive_highams_park_cp.status.should eql(:ok)
    arrive_highams_park_cp.message.should include('Processed movement type A for train 522T52M125 at HIGHAMS PARK')
    arrive_highams_park_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    arrive_highams_park_rec.locations[8].actual_arrival.should eql(DateTime.parse('2011-08-25 00:25:00'))
    arrive_highams_park_rec.departed_origin?.should be_true
    arrive_highams_park_rec.terminated?.should_not be_true
    arrive_highams_park_rec.locations[8].actual_pass.should be_nil
    arrive_highams_park_rec.locations[8].actual_departure.should be_nil
    arrive_highams_park_rec.locations[8].actual_platform.should be_nil
    arrive_highams_park_rec.locations[8].actual_line.should be_nil
    arrive_highams_park_rec.locations[8].actual_path.should be_nil

    depart_highams_park_cp = TSDBExplorer::TDnet::process_trust_message('000320110825012703TRUST               SMART                               522T52M12520110825012600527322011082501240020110825012400     00000000000000DDA  D   1522T52M125219100002121002L52731005     00000Y')
    depart_highams_park_cp.status.should eql(:ok)
    depart_highams_park_cp.message.should include('Processed movement type D for train 522T52M125 at HIGHAMS PARK')
    depart_highams_park_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    depart_highams_park_rec.departed_origin?.should be_true
    depart_highams_park_rec.terminated?.should_not be_true
    depart_highams_park_rec.locations[8].actual_arrival.should eql(DateTime.parse('2011-08-25 00:25:00'))
    depart_highams_park_rec.locations[8].actual_pass.should be_nil
    depart_highams_park_rec.locations[8].actual_departure.should eql(DateTime.parse('2011-08-25 00:26:00'))
    depart_highams_park_rec.locations[8].actual_platform.should be_nil
    depart_highams_park_rec.locations[8].actual_line.should be_nil
    depart_highams_park_rec.locations[8].actual_path.should be_nil

    arrive_chingford_cp = TSDBExplorer::TDnet::process_trust_message('000320110825013326TRUST               SMART                               522T52M12520110825013300527312011082501290020110825012900     00000000000000TAA  D   0522T52M125219100002121004L     000YY   52731Y')
    arrive_chingford_cp.status.should eql(:ok)
    arrive_chingford_cp.message.should include('Processed movement type A for train 522T52M125 at CHINGFORD')
    arrive_chingford_rec = DailySchedule.runs_on_by_uid_and_date('L06809', '2011-08-25').first
    arrive_chingford_rec.departed_origin?.should be_true
    arrive_chingford_rec.terminated?.should be_true
    arrive_chingford_rec.locations[9].actual_arrival.should eql(DateTime.parse('2011-08-25 00:33:00'))
    arrive_chingford_rec.locations[9].actual_pass.should be_nil
    arrive_chingford_rec.locations[9].actual_departure.should be_nil
    arrive_chingford_rec.locations[9].actual_platform.should be_nil
    arrive_chingford_rec.locations[9].actual_line.should be_nil
    arrive_chingford_rec.locations[9].actual_path.should be_nil

  end


  # VSTP message processing

  it "should process a VSTP CREATE message" do

    vstp_data = File.open('test/fixtures/tdnet/vstp_create_1.xml').read
    vstp_message = TSDBExplorer::TDnet::process_vstp_message(vstp_data)
    vstp_message.status.should eql(:ok)
    vstp_message.message.should include('Created VSTP schedule for train W51133 running from 20110802 to 20110802 as 1G56')

    bs_expected = { :train_uid => 'W51133', :train_identity => '1G56', :uic_code => '', :atoc_code => '', :category => 'XX', :headcode => nil, :portion_id => nil, :service_code => '24661005', :power_type => 'EMU', :timing_load => '', :speed => '', :operating_characteristics => nil, :train_class => "", :sleepers => nil, :reservations => '0', :catering_code => nil, :service_branding => nil, :status => '1', :stp_indicator => 'O',  :runs_from => Date.parse('2011-08-02'), :runs_to => Date.parse('2011-08-02'), :runs_mo => false, :runs_tu => true, :runs_we => false, :runs_th => false, :runs_fr => false, :runs_sa => false, :runs_su => false, :ats_code => 'Y', :bh_running => nil }

    vstp_schedule = BasicSchedule.find_all_by_train_uid('W51133')
    vstp_schedule.count.should eql(1)
    bs_expected.each do |k,v|
      vstp_schedule.first.send(k).should eql(v)
    end

  end

end
