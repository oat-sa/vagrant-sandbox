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

# setup the timezone
current_timezone = `cat /etc/timezone`.strip
timezone = "#{node["timezone"]["area"]}/#{node["timezone"]["zone"]}"
if timezone != current_timezone
    debconf_file = get_temp_file_path("configure")
    template debconf_file do
        source "configure.erb"
    end

    delete_file "/etc/timezone"
    delete_file "/etc/localtime"

    debconf_fix_db
    debconf_prepare debconf_file

    execute "dpkg-reconfigure --frontend noninteractive tzdata"

    delete_file debconf_file
end
