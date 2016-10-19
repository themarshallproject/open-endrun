class DomainToOrganization

  def self.data
    contents = File.read(File.join(Rails.root, 'data', 'domain_to_organization.yml'))
    return HashWithIndifferentAccess.new(YAML.load(contents))
  end

  def self.lookup(domain)
    domain = domain.to_s

    org = self.data[domain]

    if org.blank?
      return domain
    else
      return org
    end
  end

end
