json.array!(@post_deploy_tokens) do |post_deploy_token|
  json.extract! post_deploy_token, :id, :post_id, :label, :token, :active
  json.url post_deploy_token_url(post_deploy_token, format: :json)
end
