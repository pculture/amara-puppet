require 'yaml'

Facter.add("system_roles") do
  setcode do
    all_roles = Array.new
    begin
      cfg = File::open('/etc/system_roles.yml')
      roles = YAML::load(cfg.read())
      roles.each do |role|
        all_roles.push(role)
      end
    rescue
      puts 'Unable to read /etc/system_roles.yml'
    end
    all_roles
  end
end
