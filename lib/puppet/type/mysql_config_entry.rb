Puppet::Type.newtype(:mysql_config_entry) do
  @doc = "Manages entries in MySQL configuration files."

  ensurable

  def self.title_patterns
    [[ /^(.*)\/(.*)$/, [[ :section, lambda{|x| x} ], [:name, lambda{|x| x}]]],
     [ /^(.*)$/, [[ :name, lambda{|x| x} ]] ]]
  end

  newparam(:name) do
    desc "The name of the setting"
    isnamevar
  end

  newparam(:target) do
    desc "The MySQL configuration file to target."
  end

  newproperty(:value) do
    desc "Value to set for the name."
  end

  newproperty(:section) do
    desc "The section under which to store the configuration entry."
    isnamevar
  end

  autorequire(:file) do
    self[:target]
  end
end
