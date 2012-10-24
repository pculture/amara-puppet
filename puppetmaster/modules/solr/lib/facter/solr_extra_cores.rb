require 'json'

Facter.add("solr_extra_cores") do
  setcode do
    extra_cores = Array.new
    begin
      cfg = File::open('/etc/solr_extra_cores.json')
      cores = JSON.parse(cfg.read())
      cores.each do |role|
        extra_cores.push(role)
      end
    rescue
      puts 'Unable to read /etc/solr_extra_cores.json'
    end
    extra_cores.join(',')
  end
end
