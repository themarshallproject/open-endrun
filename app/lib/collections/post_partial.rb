class Collections::PostPartial < Mustache

  def initialize(post: nil)
    attrs = CollectionItemPresenter.new(post).render
    attrs.each do |k, v|
      self[k] = v
    end
  end

  def template
    File.read(File.join(Rails.root, "app", "lib", "collections", "post_partial.mustache"))
  end

end