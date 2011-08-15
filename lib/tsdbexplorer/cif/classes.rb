#
#  This file is part of TSDBExplorer.
#
#  TSDBExplorer is free software@ you can redistribute it and/or modify it
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
#  with TSDBExplorer.  If not, see <http@//www.gnu.org/licenses/>.
#
#  $Id$
#

module TSDBExplorer

  module CIF

    class HeaderRecord

      attr_reader :file_mainframe_identity, :date_of_extract, :time_of_extract, :current_file_ref, :last_file_ref, :update_indicator, :version, :user_extract_start_date, :user_extract_end_date, :mainframe_username, :extract_date
      attr_accessor :file_mainframe_identity, :date_of_extract, :time_of_extract, :current_file_ref, :last_file_ref, :update_indicator, :version, :user_extract_start_date, :user_extract_end_date, :mainframe_username, :extract_date

      def initialize(record)

        self.file_mainframe_identity = record[2..21]
        self.date_of_extract = record[22..27]
        self.time_of_extract = record[28..31]
        self.current_file_ref = record[32..38]
        self.last_file_ref = record[39..45]
        self.update_indicator = record[46..46]
        self.version = record[47..47]
        self.user_extract_start_date = record[48..53]
        self.user_extract_end_date = record[54..59]

        raise "Mainframe identity is not valid" unless self.file_mainframe_identity.match(/TPS.U(.{6}).PD(.{6})/)
        self.mainframe_username = $1
        self.extract_date = $2

      end

    end

    class TiplocRecord

      attr_reader :action, :tiploc_code, :new_tiploc, :nalco, :tps_description, :stanox, :crs_code, :description
      attr_accessor :action, :tiploc_code, :new_tiploc, :nalco, :tps_description, :stanox, :crs_code, :description

      def initialize(record)

        self.action = record[1..1]
        self.tiploc_code = record[2..8].strip
        self.nalco = record[11..16]
        self.tps_description = record[18..43]
        self.stanox = record[44..48]
        self.crs_code = record[53..55]
        self.description = record[56..72]
        self.new_tiploc = record[73..77] if self.action == "A"

        self.description = self.description.strip.empty? ? nil : self.description.strip unless self.description.nil?
        self.tps_description = self.tps_description.strip.empty? ? nil : self.tps_description.strip unless self.tps_description.nil?

        self.stanox = nil if self.stanox == "00000"

      end

    end

    class LocationRecord

      attr_reader :basic_schedule_uuid, :record_identity, :location_type, :tiploc_code, :tiploc_instance, :arrival, :public_arrival, :pass, :departure, :public_departure, :platform, :line, :path, :engineering_allowance, :pathing_allowance, :performance_allowance, :activity
      attr_accessor :basic_schedule_uuid, :record_identity, :location_type, :tiploc_code, :tiploc_instance, :arrival, :public_arrival, :pass, :departure, :public_departure, :platform, :line, :path, :engineering_allowance, :pathing_allowance, :performance_allowance, :activity

      def initialize(record=nil)

        if record

          self.location_type = record[0..1]
          self.record_identity = self.location_type
          self.tiploc_code = record[2..8].strip
          self.tiploc_instance = record[9..9]

          if self.location_type == "LO"
            self.departure = record[10..14]
            self.public_departure = record[15..18]
            self.platform = record[19..21].strip
            self.line = record[22..24].strip
            self.engineering_allowance = record[25..26].strip
            self.pathing_allowance = record[27..28].strip
            self.activity = record[29..40].strip
            self.performance_allowance = record[41..42].strip
          elsif self.location_type == "LI"
            self.arrival = record[10..14]
            self.departure = record[15..19]
            self.pass = record[20..24]
            self.public_arrival = record[25..28]
            self.public_departure = record[29..32]
            self.platform = record[33..35].strip
            self.line = record[36..38].strip
            self.path = record[39..41].strip
            self.activity = record[42..53].strip
            self.engineering_allowance = record[54..55].strip
            self.pathing_allowance = record[56..57].strip
            self.performance_allowance = record[58..59].strip
          elsif self.location_type == "LT"
            self.arrival = record[10..14]
            self.public_arrival = record[15..18]
            self.platform = record[19..21].strip
            self.path = record[22..24].strip
            self.activity = record[25..36].strip
          else
            raise "Unknown location type '#{self.location_type}'"
          end

          self.tiploc_instance = nil if self.tiploc_instance == " "
          self.arrival = nil if self.arrival == "     "
          self.departure = nil if self.departure == "     "
          self.pass = nil if self.pass == "0000 " || self.pass == "     "
          self.public_arrival = nil if self.public_arrival == "0000"
          self.public_departure = nil if self.public_departure == "0000"
          self.line = nil if self.line == ""
          self.activity = nil if self.activity == ""
          self.path = nil if self.path == ""
          self.platform = nil if self.platform == ""
          self.pathing_allowance = nil if self.pathing_allowance == ""
          self.engineering_allowance = nil if self.engineering_allowance == ""
          self.performance_allowance = nil if self.performance_allowance == ""

        end

      end

    end

    class BasicScheduleExtendedRecord

      attr_reader :traction_class, :uic_code, :atoc_code, :ats_code, :rsid, :data_source
      attr_accessor :traction_class, :uic_code, :atoc_code, :ats_code, :rsid, :data_source

      def initialize(record)

        self.traction_class = record[2..5].strip
        self.uic_code = record[6..10]
        self.atoc_code = record[11..12]
        self.ats_code = record[13..13]
        self.rsid = record[15..22].strip
        self.data_source = record[23..23].strip

        self.traction_class = self.traction_class.strip.empty? ? nil : self.traction_class.strip
        self.uic_code = self.uic_code.strip.empty? ? nil : self.uic_code.strip
        self.rsid = self.rsid.strip.empty? ? nil : self.rsid.strip
        self.data_source = self.data_source.strip.empty? ? nil : self.data_source.strip

      end

    end

    class BasicScheduleRecord

      attr_reader :uuid, :transaction_type, :train_uid, :train_identity_unique, :runs_from, :runs_to, :runs_mo, :runs_tu, :runs_we, :runs_th, :runs_fr, :runs_sa, :runs_su, :bh_running, :status, :category, :train_identity, :headcode, :course_indicator, :service_code, :portion_id, :power_type, :timing_load, :speed, :operating_characteristics, :train_class, :sleepers, :reservations, :connection_indicator, :catering_code, :service_branding, :stp_indicator, :uic_code, :atoc_code, :ats_code, :rsid, :data_source
      attr_accessor :uuid, :transaction_type, :train_uid, :train_identity_unique, :runs_from, :runs_to, :runs_mo, :runs_tu, :runs_we, :runs_th, :runs_fr, :runs_sa, :runs_su, :bh_running, :status, :category, :train_identity, :headcode, :course_indicator, :service_code, :portion_id, :power_type, :timing_load, :speed, :operating_characteristics, :train_class, :sleepers, :reservations, :connection_indicator, :catering_code, :service_branding, :stp_indicator, :uic_code, :atoc_code, :ats_code, :rsid, :data_source

      def initialize(record)

        self.transaction_type = record[2..2]
        self.train_uid = record[3..8]
        self.runs_from = TSDBExplorer::yymmdd_to_date(record[9..14])
        self.runs_to = TSDBExplorer::yymmdd_to_date(record[15..20])
        self.runs_mo = record[21..21]
        self.runs_tu = record[22..22]
        self.runs_we = record[23..23]
        self.runs_th = record[24..24]
        self.runs_fr = record[25..25]
        self.runs_sa = record[26..26]
        self.runs_su = record[27..27]
        self.bh_running = record[28..28].strip
        self.status = record[29..29]
        self.category = record[30..31]
        self.train_identity = record[32..35]
        self.headcode = record[36..39].strip
        self.service_code = record[41..48]
        self.portion_id = record[49..49].strip
        self.power_type = record[50..52]
        self.timing_load = record[53..56]
        self.speed = record[57..59]
        self.operating_characteristics = record[60..65].strip
        self.train_class = record[66..66]
        self.sleepers = record[67..67].strip
        self.reservations = record[68..68].strip
        self.catering_code = record[70..73].strip
        self.service_branding = record[74..77].strip
        self.stp_indicator = record[79..79]

        self.bh_running = nil if self.bh_running == ""
        self.headcode = nil if self.headcode == ""
        self.portion_id = nil if self.portion_id == ""
        self.operating_characteristics = nil if self.operating_characteristics == ""
        self.sleepers = nil if self.sleepers == ""
        self.reservations = nil if self.reservations == ""
        self.catering_code = nil if self.catering_code == ""
        self.service_branding = nil if self.service_branding == ""

      end

      def merge_bx_record(bx_record)

        raise "A BasicScheduleExtended object must be passed" unless bx_record.is_a? TSDBExplorer::CIF::BasicScheduleExtendedRecord

        self.uic_code = bx_record.uic_code
        self.atoc_code = bx_record.uic_code
        self.ats_code = bx_record.ats_code
        self.rsid = bx_record.rsid
        self.data_source = bx_record.data_source

      end

    end

  end

end
