Puppet::Type.type(:package).provide :x_yum, :parent => :yum do
    defaultfor :osfamily => :redhat, :operatingsystem => :fedora
end

