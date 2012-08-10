Facter.add("is_vagrant") do
  setcode do
    File.exist? "/home/vagrant"
  end
end
