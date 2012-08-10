Facter.add("is_vagrant") do
  confine :kernel => "Linux"
  setcode do
    is_vagrant = false
    if File.exist? "/home/vagrant"
      is_vagrant = true
    end
    is_vagrant
  end
end
