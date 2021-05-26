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

if not package_installed?("apache2")
    # install apache and dependencies
    packages =  [
        "apache2",
        "apache2-utils"
    ]
    install_packages_once packages

    # setup permissions
    user = get_user
    execute "adduser www-data #{user}"
    execute "usermod -a -G www-data #{user}"

    # install Apache2 modules
    apache_modules = [
        "rewrite",
        "ssl",
        "headers",
        "alias",
        "vhost_alias"
    ]
    apache_modules.each do |name|
        execute "a2enmod #{name}"
    end

    # set a SSl security group
    security_group = "dhparam.pem"
    ssl_dh_group(security_group)
    template "/etc/apache2/conf-available/ssl-params.conf" do
        source "ssl-params.erb"
        variables(
            :security_group => security_group
        )
        action :create
    end
    execute "a2enconf ssl-params.conf"

    service "apache2" do
        action :restart
    end
end
