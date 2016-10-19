json.array!(@asset_files) do |asset_file|
  json.extract! asset_file, :id, :asset_id, :s3_bucket, :s3_key
  json.url asset_file_url(asset_file, format: :json)
end
