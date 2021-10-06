#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; under version 2
# of the License (non-upgradable).
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# Copyright (c) 2020 (original work) Open Assessment Technologies SA;
#

# creates a MySQl user
def mysql_create_user(user, password, rootpwd)
    execute_template("user.erb", {
        :user => user,
        :password => password,
        :root_password => rootpwd
    }, "mysql")
end

# creates a MySQl database, unless it already exists
def mysql_create_database(database, user, password, collation='utf8_general_ci')
    execute_template("database.erb", {
        :user => user,
        :password => password,
        :database => database,
        :collation => collation
    }, "mysql")
end
