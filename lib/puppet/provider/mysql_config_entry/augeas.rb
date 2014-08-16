Puppet::Type.type(:mysql_config_entry).provide(:augeas, :parent => Puppet::Type.type(:augeasprovider).provider(:default)) do
  desc "Uses Augeas to update MySQL configuration files."

  confine :feature => :augeas
  default_file { '/etc/mysql/my.cnf' }
  lens { 'MySQL.lns' }

  resource_path do |resource|
    "$target/target[.='#{resource[:section]}']/#{resource[:name]}"
  end

  mk_resource_methods

  def self.instances
    resources = []
    augopen do |aug|
      aug.match("$target/*").each do |spath|

        basename = spath.split("/")[-1]
        name = basename.split("[")[0]
        next unless name
        next if name == "#comment"

        aug.match("#{spath}/*").each do |key|
          unless File.basename(key) =~ /^#comment(\[\d+\])?$/
            target = File.dirname(spath)
            # Strips off the /files
            target.slice!('/files')
            key = File.basename(key)
            section  = aug.get("#{spath}")
            resource = { :ensure  => :present,
                         :name    => "#{section}/#{key}",
                         :section => section,
                         :target  => target,
                         :value   => aug.get(key)}
            resources << new(resource)
          end
        end
      end
    end
    resources
  end

  attr_aug_accessor(:value, :label => :resource)
  attr_aug_accessor(:section, :label => :resource)

end
