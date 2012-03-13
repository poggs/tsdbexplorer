//
//  This file is part of TSDBExplorer.
//
//  TSDBExplorer is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the
//  Free Software Foundation, either version 3 of the License, or (at your
//  option) any later version.
//
//  TSDBExplorer is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
//  Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with TSDBExplorer.  If not, see <http://www.gnu.org/licenses/>.
//
//  $Id$
//

function load_handler() {

  // Update the value of an element whose ID is 'time', if it exists

  if ($('#time').length != 0) {

    var current_time = new Date();

    var hour = current_time.getHours();
    if(hour < 10) { hour = "0" + hour }

    var minute = current_time.getMinutes();
    if(minute < 10) { minute = "0" + minute }

    $('#time')[0].value = hour + ":" + minute;

  }

  // Activate popovers and dropdowns

  $('[rel=popover]').popover({ placement: 'bottom', delay: 500 });
  $('.dropdown-toggle').dropdown();

}
