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

if not package_installed?("mysql-server")
    # install MySQL Server using aptitude
    install_packages_once [ "mysql-server", "expect" ]

    # configure the security
    execute_template("configure.erb", {
        :old_password => "",
        :new_password => node["mysql"]["password"]
    })

    # set the default authentication plugin
    cookbook_file "/etc/mysql/mysql.conf.d/user.cnf" do
        source "user.cnf"
        mode 0644
        action :create
    end

    service "mysql" do
        action :restart
    end

    # setup user
    mysql_create_user(
        node["mysql"]["user"],
        node["mysql"]["password"],
        node["mysql"]["password"]
    )
end