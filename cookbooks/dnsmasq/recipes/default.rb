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

# install Dnsmasq using aptitude
if not package_installed?("dnsmasq")
    install_packages_once [ "dnsmasq" ]
    service "systemd-resolved" do
        action :stop
    end
    service "systemd-resolved" do
        action :disable
    end
end

if node["hosts"]
    directory "/etc/resolver"

    Array(node["hosts"]).each do |domain, path|
        variables = { :domain => domain }

        template "/etc/dnsmasq.d/#{domain}.conf" do
            source "domain.erb"
            variables variables
            action :create
        end

        template "/etc/resolver/#{domain}" do
            source "resolver.erb"
            variables variables
            action :create
        end
    end

    service "dnsmasq" do
        action :restart
    end
end
