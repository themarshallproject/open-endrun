json.array!(@letters) do |letter|
  json.extract! letter, :id, :name, :email, :twitter, :street_address, :is_anonymous, :content, :post_id, :status, :stream_promo, :excerpt
  json.url letter_url(letter, format: :json)
end
