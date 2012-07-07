Facter.add("system_env") do
  setcode do
    begin
      env = File::read('/etc/system_env').strip
    rescue
      puts "Unable to read /etc/system_env"
      env = nil
    end
    env
  end
end