Facter.add("is_vagrant") do
  setcode do
    vagrant = false
    if File.exist? "/home/vagrant"
        vagrant = true
    elsif File.exist? "/home/sandbox"
        vagrant = true
    end
    vagrant
  end
end
