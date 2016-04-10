Facter.add(:jenkins_sshrsa) do
    confine :fqdn => 'jenkins.phx.ovirt.org'
    setcode do
        # this has to be hard-coded, as facts are loaded
        # prior to catalog completion.
        filepath = '/var/lib/data/jenkins/.ssh/id_rsa.pub'
        if File.exist? filepath
                File.read(filepath).chomp.split(' ')[1]
        end
    end
end
