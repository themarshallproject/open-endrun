class PrintRenderer

  def initialize(post)
    $stdout.puts("count#app.print_renderer_initialize=1")
    @post = post
    puts "PrintRenderer initialize for #{@post.path}"
  end

  def render()
    start_time = Time.now.utc.to_f

    content = @post.content

    html = render_markdown(content)
    html = StripExtraPTag.parse(html)

    document = Nokogiri::HTML.fragment(html)

    document.css('*').each do |el|
      el.remove unless ['a', 'p', 'em', 'strong'].include?(el.name)
    end

    html = document.to_html

    html = [
      ShortcodeDropcap,
      ShortcodeSubhead,
      ShortcodeQuote,
    ].reduce(html) do |input, middleware|
      middleware.parse(input)
    end

    html = ShortcodeGraphic.parse(html, @post.id)
    html = ShortcodePhoto.parse(html, @post.id)

    document = Nokogiri::HTML.fragment(html)
    document.css('.photo-max').each do |el|
      el['class'] = 'photo-hammer'
    end
    document.css('.photo-max-shim').each do |el|
      el['style'] = "position: static; height: auto;"
    end

    html = document.to_html

    puts "measure#print_render=#{1000*(Time.now.utc.to_f-start_time)}ms" # Librato

    return html.html_safe
  end

  def render_markdown(content)
    options = {
      autolink: false,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true,
      disable_indented_code_blocks: true
    }

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, options)
    markdown.render(content).html_safe
  end

end
