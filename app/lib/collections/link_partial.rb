class Collections::LinkPartial < Mustache

  def initialize(link: nil)
    attrs = CollectionItemPresenter.new(link).render
    attrs.each do |k, v|
      self[k] = v
    end
  end

  def template
    File.read(File.join(Rails.root, "app", "lib", "collections", "link_partial.mustache"))
  end

end