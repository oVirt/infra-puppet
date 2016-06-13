Facter.add(:superdomain) do
  setcode do
    domain = Facter.value(:domain)
    domain or return
    domain[/\A([^\.]+\.)?(([^\.]+\.)+[^\.]+)\z/,2]
  end
end

Facter.add(:tld) do
  setcode do
    domain = Facter.value(:domain)
    domain or return
    domain[/\A.*?\.?([^\.]+)\z/,1]
  end
end
