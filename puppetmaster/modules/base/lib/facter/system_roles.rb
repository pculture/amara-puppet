require 'yaml'

Facter.add("system_roles") do
  setcode do
    roles = Array.new
    begin
      cfg = File::open('/etc/system_roles.yml')
      roles = YAML::load(cfg.read())
    rescue
      puts 'Unable to read /etc/system_roles.yml'
    end
    roles
  end
end