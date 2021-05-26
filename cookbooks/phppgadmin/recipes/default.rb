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

# install phpPgAdmin using aptitude
if not package_installed?("phppgadmin")
    install_packages_once [ "phppgadmin" ]

    alias_file = "/etc/apache2/conf-available/phppgadmin.conf"
    replace_in_file(alias_file, /^AllowOverride None$/, "AllowOverride All")
    replace_in_file(alias_file, /^Require local$/, "Require all granted")

    service "apache2" do
        action :restart
    end
end