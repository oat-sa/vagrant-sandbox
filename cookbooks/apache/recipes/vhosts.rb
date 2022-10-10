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

# install the dynamic sites
if node["hosts"]
    Array(node["hosts"]).each do |domain, path|
        ssl_cert(domain)

        template "/etc/apache2/sites-available/vhost-#{domain}.conf" do
            source "vhost.erb"
            variables(
                :db_user => node["pgsql"]["user"],
                :db_password => node["pgsql"]["password"],
                :domain => domain,
                :dynamic => path =~ /%\d+/,
                :path => path
            )
            action :create
        end

        execute "a2ensite vhost-#{domain}.conf"
    end

    service "apache2" do
        action :restart
    end
end
