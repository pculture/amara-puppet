require 'yaml'
Facter.add("environments") do
  setcode do
    environments = Array.new
    begin
      cfg = File::open('/etc/system_environments.yml')
      yml = YAML::load(cfg.read())
      environments = yml['environments']
    rescue
      puts 'Unable to read /etc/system_environments.yml'
    end
    environments
  end
end