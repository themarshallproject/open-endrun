class PublicPostPreview

  def self.generate_token(post_id: nil, slug: "")
    post = Post.find(post_id)

    return JWT.encode(
      {
        slug: slug,
        post_id: post.id,
        exp: Time.now.to_i + 7.days.to_i
      },
      ENV['LINK_DECODE_HMAC_SECRET_V1'],
      'HS256'
    )
  end

  def self.post_from_token(token)
    data, _info = JWT.decode(token, ENV['LINK_DECODE_HMAC_SECRET_V1'], true)
    expires_in = {now: Time.now, exp: Time.at(data['exp'])}

    puts "PublicPostPreview#post_from_token token=#{token} data=#{data.to_json}"

    valid_slugs = (ENV['PUBLIC_POST_PREVIEW_ACTIVE_SLUGS'] || '').split(',')

    if valid_slugs.include?(data['slug'])
      return Post.find(data['post_id'])
    end

    return nil
  end

end
