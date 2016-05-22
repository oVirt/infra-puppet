# in puppet master 3.7.4, this line was not added yet to systemd.rb
# causing puppet to use chkconfig instead of systemd on fedora, which fails
# all runs. this patch should be removed once we upgrade to a newer version
Puppet::Type.type(:service).provide :x_systemd, :parent => :systemd do
    defaultfor :osfamily => :redhat, :operatingsystem => :fedora
end
