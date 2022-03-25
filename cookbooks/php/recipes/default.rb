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

php_version = node["php"]["version"]
if command_exists?("php")
    installed_version = `php -v | grep -Po "(?<=PHP )\\d.\\d"`.strip
else
    installed_version = ""
end

if php_version != installed_version
    # install required packages
    required_packages = [
        "unzip",
        "python-software-properties",
        "software-properties-common"
    ]
    install_packages_once required_packages
    add_ppa_repository "ondrej/php"

    # install PHP packages
    php_packages = [
        "php#{php_version}",
        "php#{php_version}-common",
        "php#{php_version}-dev",
        "libapache2-mod-php#{php_version}",
        "php#{php_version}-mysql",
        "php#{php_version}-pgsql",
        "php#{php_version}-curl",
        "php#{php_version}-gd",
        "php#{php_version}-intl",
        "php#{php_version}-mcrypt",
        "php#{php_version}-imap",
        "php#{php_version}-pspell",
        "php#{php_version}-recode",
        "php#{php_version}-sqlite3",
        "php#{php_version}-tidy",
        "php#{php_version}-xmlrpc",
        "php#{php_version}-xml",
        "php#{php_version}-xsl",
        "php#{php_version}-mbstring",
        "php#{php_version}-zip",
        "php#{php_version}-redis",
        "php-apcu",
        "php-pear",
        "php-imagick",
        "php-memcache",
        "php-gettext"
    ]
    install_packages_once php_packages

    # disable installed version of PHP
    if not installed_version.empty?
        execute "a2dismod php#{installed_version}"
    end

    # then activate the required version
    execute "a2enmod php#{php_version}"
    service "apache2" do
        action :restart
    end

    execute "update-alternatives --set php /usr/bin/php#{php_version}"
    execute "update-alternatives --set phar /usr/bin/phar#{php_version}"
    execute "update-alternatives --set phar.phar /usr/bin/phar.phar#{php_version}"
    execute "update-alternatives --set phpize /usr/bin/phpize#{php_version}"
    execute "update-alternatives --set php-config /usr/bin/php-config#{php_version}"
end
