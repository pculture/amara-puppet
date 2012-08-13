require 'yaml'
Facter.add("system_environments") do
  setcode do
   all_environments = Array.new
    begin
      cfg = File::open('/etc/system_environments.yml')
      environments = YAML::load(cfg.read())
      environments.each do |env|
        all_environments.push(env)
      end
    rescue
      puts 'Unable to read /etc/system_environments.yml'
    end
    all_environments
  end
end
