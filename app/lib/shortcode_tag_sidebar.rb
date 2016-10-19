class ShortcodeTagSidebar


  def self.extract_attrs(str)
    str.split(' ').inject({}) do |obj, item|
      k, v = item.split('=')
      obj[k.to_sym] = v
      obj
    end
  end

  def self.fragment_builder
    builder_doc = Nokogiri::HTML::DocumentFragment.parse ''
    Nokogiri::HTML::Builder.with(builder_doc) do |doc|
      yield doc
    end
    builder_doc.to_html
  end

	def self.parse(full_text, post_id)
		selector_regex = /\[tag-sidebar(.*?)\]/


    full_text.gsub!(selector_regex) do |capture|
        attrs = self.extract_attrs($1)        
        tag  = Tag.where(id: attrs[:tag_id]).first
        post = Post.find(post_id)

        puts "ShortcodeTagSidebar: #{attrs.inspect}"

        if tag.present? and attrs[:v] == '1'
          self.template_v1(tag: tag, post: post)
        else
          "<div>no-doc</div>"
        end

    end

    full_text

	end

  private

    # def self.template_v1(tag: nil, post: nil)
    #   puts "#{tag} #{post}"
    #   posts = [1, 2]

    #   fragment_builder do |doc|
    #     doc.ul class: 'related' do

    #       posts.each do |post|
    #         doc.li class: 'item' {
    #           [
    #             doc.div class: 'date' {
    #               doc.span {
    #                 "01.01.2015"
    #               }
    #             },
    #             doc.div class: 'headline' {
    #               doc.a href: '#href' {
    #                 "headline"
    #               }
    #             }
    #           ]
    #         }
    #       end
    #     end
        
    #   end
    # end

  
end