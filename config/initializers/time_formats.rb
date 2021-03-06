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

Time::DATE_FORMATS[:iso] = '%Y-%m-%d %H:%M:%S'
Time::DATE_FORMATS[:yyyymmdd] = '%Y-%m-%d'
Time::DATE_FORMATS[:hhmm] = '%H%M'
Time::DATE_FORMATS[:hhmm_colon] = '%H:%M'

Time::DATE_FORMATS[:human] = lambda { |date| "#{date.strftime('%A')} #{date.day.ordinalize} #{date.strftime('%B %Y')}, #{date.strftime('%H:%M')}" }
Date::DATE_FORMATS[:default] = lambda { |date| "#{date.strftime('%A')} #{date.day.ordinalize} #{date.strftime('%B %Y')}" }
