class PhotoAspectRatioWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def endpoint(photo)
    "https://tmp-photo-aspect-ratio.herokuapp.com/api/v1?url=#{photo.original_url}"
  end

  def ratio(json)
    data = JSON.parse(json)
    if data['width'] == 0 or data['height'] == 0
      raise "PhotoAspectRatioWorker Error : returned zero for width or height"
    end

    return 1.0 * data['width'] / data['height']
  end

  def perform(photo_id)
    photo = Photo.find_by(id: photo_id)
    if photo.nil?
      return false
    end

    response = HTTParty.get(endpoint(photo), timeout: 2)

    if response.code != 200
      puts "PhotoAspectRatioWorker Error : service returned a non-200 code. body: #{response.body.to_json}"
      return false
    end

    photo.aspect_ratio = ratio(response.body)
    return photo.save
  end

end
