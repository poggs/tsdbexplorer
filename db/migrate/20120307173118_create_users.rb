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

class CreateUsers < ActiveRecord::Migration

  def change

    create_table :users do |t|

      t.string     :email, :null => false, :default => ''
      t.string     :encrypted_password, :null => false, :default => ''
      t.text       :full_name
      t.string     :reset_password_token
      t.datetime   :reset_password_sent_at
      t.datetime   :remember_created_at
      t.integer    :sign_in_count, :default => 0
      t.datetime   :current_sign_in_at
      t.datetime   :last_sign_in_at
      t.string     :current_sign_in_ip
      t.string     :last_sign_in_ip
      t.string     :password_salt
      t.string     :confirmation_token
      t.datetime   :confirmed_at
      t.datetime   :confirmation_sent_at
      t.integer    :failed_attempts, :default => 0
      t.string     :unlock_token
      t.datetime   :locked_at
      t.boolean    :is_admin
      t.boolean    :enabled
      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token,   :unique => true
    add_index :users, :unlock_token,         :unique => true

  end

end
