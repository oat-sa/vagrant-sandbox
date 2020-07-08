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

# checks if a command exists
def command_exists?(name)
    return !`which #{name}`.empty?
end

# checks if a package is available
def package_available?(name)
    return !`apt-cache search #{name}`.empty?
end

# checks if a package is installed
def package_installed?(name)
    return !`dpkg -l | grep #{name}`.empty?
end

# installs the packages if:
# - they are available from the repositories
# - they are not already installed
def install_packages_once(packages)
    packages.each do |name|
        package "#{name}" do
            only_if { package_available?(name) and not package_installed?(name) }
        end
    end
end

# checks if the PPA repository has been added
def ppa_repository_installed?(repository)
    return !`apt-cache policy | grep #{repository}`.empty?
end

# adds the PPA repository
def add_ppa_repository(repository)
    if not ppa_repository_installed?(repository)
        execute "add-apt-repository -y ppa:#{repository}"
        execute "apt-get update -y"
    end
end

# fixes debconf database
def debconf_fix_db()
    execute "/usr/share/debconf/fix_db.pl"
end

# prepares non-interactive package install
def debconf_prepare(config_file)
    bash "prepare non-interactive install" do
        code <<-EOH
            export DEBIAN_FRONTEND="noninteractive"
            export DEBCONF_NONINTERACTIVE_SEEN=true
            debconf-set-selections #{config_file}
        EOH
    end
end

# gets the actual user
def get_user()
    user = ENV["SUDO_USER"]
    unless user
        user = node["current_user"]
    end
    return user
end

# checks if a file contains a text
def inFile?(path, text)
    return ::File.readlines(path).grep(/#{Regexp.escape(text)}/).size > 0
end

# deletes a file
def delete_file(path)
    file path do
        action :delete
    end
end

# generates the path for a temporary file
def get_temp_file_path(name)
    return File.join(Chef::Config[:file_cache_path], name)
end

# generates a SSL certificate
def ssl_cert(domain, destination="/var/ssl/cert", rewrite=true)
    crt_path = "#{destination}/#{domain}.crt"
    key_path = "#{destination}/#{domain}.key"

    if not File.exist?(crt_path) or rewrite

        directory "#{destination}" do
            action :create
            recursive true
        end

        config_file = get_temp_file_path("req.cnf")

        template config_file do
            cookbook "shared-resources"
            source "config-ssl.erb"
            variables(
                :domain => domain
            )
            action :create
        end

        execute "openssl req -x509 -nodes -newkey rsa:4096 -sha256 -keyout #{key_path} -out #{crt_path} -days 365 -config #{config_file}"

        delete_file config_file
    end
end

# runs a script generated from a template
def execute_template(source, variables = nil, cookbook = nil)
    generated_script = get_temp_file_path("generated_script.sh")
    template generated_script do
        cookbook cookbook
        source source
        mode 0777
        variables variables
    end
    execute generated_script
    delete_file generated_script
end

# replaces a text in a file using RegEx
def replace_in_file(path, from, to)
    ruby_block "replace in file" do
        block do
            text = File.read(path)
            new_contents = text.gsub(from, to)
            puts new_contents
            File.open(path, "w") {|file| file.puts new_contents }
        end
        action :run
    end
end
