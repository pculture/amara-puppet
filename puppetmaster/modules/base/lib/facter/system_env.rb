require 'yaml'

Facter.add("system_environments") do
  setcode do
    all_envs = Array.new
    begin
      cfg = File::open('/etc/system_environments.yml')
      envs = YAML::load(cfg.read())
      envs.each do |env|
        all_envs.push(env)
      end
    rescue
      puts 'Unable to read /etc/system_environments.yml'
    end
    all_envs.join(',')
  end
end
