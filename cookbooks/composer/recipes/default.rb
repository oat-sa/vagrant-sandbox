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
# Copyright (c) 2020-2022 (original work) Open Assessment Technologies SA;
#

if not File.exist?(node["composer"]["bin"])
    # install Composer using the installer
    execute_template("install.erb", {
        :bin => node["composer"]["bin"],
    }, "composer")

    # configure default
    home = Dir.home(get_user)
    directory "#{home}/.composer/"
    cookbook_file "#{home}/.composer/config.json" do
        source "config.json"
        action :create
    end
end
