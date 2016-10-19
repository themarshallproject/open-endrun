class PostRenderer

  def initialize(post)
    $stdout.puts("count#app.post_renderer_initialize=1")
    @post = post
  end

  def render()
    start_time = Time.now.utc.to_f

    # stage 1: process raw input into markdown html
    document = render_markdown()

    # stage 2: strip empty <p>, so when we expand shortcodes they aren't wrapped
    document =       StripExtraPTag.parse(document)

    # stage 3: expand shortcodes
    document =        ShortcodeList.parse(document, @post.id)
    document =     ShortcodeGraphic.parse(document, @post.id)
    document =      ShortcodeAssets.parse(document)
    document =         ShortcodeTag.parse(document, @post.id)
    document =       ShortcodeTweet.parse(document, @post.id)
    document =       ShortcodeQuote.parse(document)
    document =       ShortcodePhoto.parse(document, @post.id)
    document =     ShortcodeDropcap.parse(document)
    document =     ShortcodeSubhead.parse(document)

    document =         ShortcodeSidebar.parse(document)
    document =     ShortcodeSidebarLeft.parse(document, @post.id)
    document =      ShortcodeAnnotation.parse(document)
    document =         ShortcodeDivider.parse(document)
    document =    ShortcodeSectionBreak.parse(document, @post.id)
    document =     ShortcodeSidebarNote.parse(document, @post.id)


    puts "measure#post_render=#{1000*(Time.now.utc.to_f-start_time)}ms" # Librato

    return document
  end

  def render_markdown()
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
    markdown.render(@post.content).html_safe
  end

end
