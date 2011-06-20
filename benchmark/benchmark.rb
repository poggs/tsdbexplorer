#!/usr/bin/ruby
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

=begin rdoc

Benchmark database performance by processing a CIF file with a single
BasicSchedule running on 260 days in a year, with 26 calling points each. 

Given a baseline for performance, code and database changes can be made and
improvements accurately tracked.

=end

require ::File.expand_path('../../config/environment',  __FILE__)

require 'benchmark'
Rails.logger.level = 0

puts Benchmark.measure { TSDBExplorer::CIF::process_cif_file('benchmark/BENCHMARK.CIF') }
