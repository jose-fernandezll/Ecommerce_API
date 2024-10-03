module ApiHelpers
  def json_body
    JSON.parse(response.body)
  end

  def serialized_body(serializer, resource)
    serializer_class = serializer.constantize
    JSON.parse(
      serializer_class.new(resource).serializable_hash.to_json
    )
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end