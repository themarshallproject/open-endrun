namespace :posts do
  desc "TODO"
  task test_post_renderer: :environment do
    puts Post.order(:id).all.map{ |post|
      html = post.rendered_content
      "post id=#{post.id} title=#{post.title} emitted HTML count=#{html.length}"
    }
  end

  task bake: :environment do
    puts JSON.pretty_generate Post.published.order(:id).all.map{|post|
      {
        id: post.id,
        path: post.path,
        title: post.title,
        deck: post.deck,
        markdown: post.content,
        html: post.rendered_content
      }
    }
  end

  task export: :environment do
    Post.published.order('updated_at DESC').all.each do |post|
      puts "Generating '#{post.title}'"
      json = JSON.pretty_generate(post.serialize)
      path = File.join(Rails.root, "data", "posts", "#{post.id}.json")
      File.open(path, "w") do |f|
        f.puts(json)
      end
    end
  end

end
