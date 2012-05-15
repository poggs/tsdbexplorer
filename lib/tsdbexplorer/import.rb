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

module TSDBExplorer

  module Import

    # Import the location data set

    def Import.locations(filename='data/static/locations.csv')

      return Struct.new(:status, :message).new(:status => :error, :message => "Location data not found at #{filename}") unless File.readable?(filename)

      # Wrap everything in a Redis transaction

      $REDIS.multi do

        old_tiplocs = $REDIS.keys("TIPLOC:*")

        unless old_tiplocs.nil?
          old_tiplocs.each do |t|
            $REDIS.del(t)
          end
        end


        old_name_to_tiploc = $REDIS.keys("NAME:TO-TIPLOC:*")

        unless old_name_to_tiploc.nil?
          old_name_to_tiploc.each do |tn|
            $REDIS.del(tn)
          end
        end


        old_stanox = $REDIS.keys("STANOX:*")

        unless old_stanox.nil?
          old_stanox.each do |s|
            $REDIS.del(s)
          end
        end

        location_records = Array.new

        CSV.foreach(filename, { :col_sep => ";" }) do |location|

          location_records << Point.new(:full_name => location[0], :short_name => location[1], :stanox => location[2], :stanme => location[3], :tiploc => location[5], :latitude => location[6], :longitude => location[7])

          $REDIS.hset("TIPLOC:#{location[5]}", "full_name", location[0])
          $REDIS.hset("TIPLOC:#{location[5]}", "short_name", location[0])
          $REDIS.hset("TIPLOC:#{location[5]}", "stanme", location[3])

          Text::Metaphone.metaphone(location[0]).split(' ').each do |m|
            $REDIS.sadd("FUZZY-NAME:TO-TIPLOC:#{m}", location[5])
          end

          $REDIS.set("NAME:TO-TIPLOC:#{TSDBExplorer::strip_and_upcase(location[0])}", location[5])

          $REDIS.hset("STANOX:#{location[2]}", "tiploc", location[5])
        end


        # Delete the on-disk records and import the new ones in a single transaction

        ActiveRecord::Base.transaction do
          Point.delete_all
          location_result = Point.import(location_records)
        end

      end

      return Struct.new(:status, :message).new(:status => :ok, :message => "Import succesful")

    end


    # Import the CRS-to-TIPLOC mapping data set

    def Import.crs_to_tiploc(filename='data/static/crs-to-tiploc.csv')

      return Struct.new(:status, :message).new(:status => :error, :message => "CRS to TIPLOC data not found at #{filename}") unless File.readable?(filename)

      # Wrap everything in a Redis transaction

      $REDIS.multi do

        old_crs_to_tiploc = $REDIS.keys("CRS:TO-TIPLOC:*")

        unless old_crs_to_tiploc.nil?
          old_crs_to_tiploc.each do |ct|
            $REDIS.del(ct)
          end
        end

        old_crs_to_name = $REDIS.keys("CRS:TO-NAME:*")

        unless old_crs_to_name.nil?
          old_crs_to_name.each do |cn|
            $REDIS.del(cn)
          end
        end

        old_name_to_crs = $REDIS.keys("NAME:TO-CRS:*")

        unless old_name_to_crs.nil?
          old_name_to_crs.each do |nc|
            $REDIS.del(nc)
          end
        end

        CSV.foreach(filename, { :col_sep => ";" }) do |crs_code|
          crs_code[2].split(",").each do |tiploc|
            $REDIS.sadd("CRS:TO-TIPLOC:#{crs_code[0]}", tiploc)
            $REDIS.set("CRS:TO-NAME:#{crs_code[0]}", crs_code[1])
            $REDIS.set("NAME:TO-CRS:#{TSDBExplorer::strip_and_upcase(crs_code[1])}", crs_code[0])
#            $REDIS.set("FUZZY-NAME:TO-CRS:#{Text::Metaphone.metaphone(crs_code[1])}", crs_code[0])

             Text::Metaphone.metaphone(crs_code[1]).split(' ').each do |m|
               $REDIS.sadd("FUZZY-NAME:TO-CRS:#{m}", crs_code[0])
             end

          end

        end

      end

      return Struct.new(:status, :message).new(:status => :ok, :message => "Import succesful")

    end

  end

end
