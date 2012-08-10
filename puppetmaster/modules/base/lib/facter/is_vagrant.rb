Facter.add("is_vagrant") do
  confine :kernel => "Linux"
  setcode do
    File.exist? "/home/vagrant"
  end
end
