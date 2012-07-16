Facter.add("is_vagrant") do
  confine :kernel => "Linux"
  setcode do
    is_vagrant = false
    if File.exist? "/home/vagranta"
      is_vagrant = true
    end
    puts is_vagrant
    is_vagrant
  end
end