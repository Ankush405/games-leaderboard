# app/controllers/concerns/hmac_request_verifier.rb
module HmacRequestVerifier
  extend ActiveSupport::Concern

  included do
    before_action :verify_hmac_request, only: [:submit]
  end

  def verify_hmac_request
    timestamp = request.headers['X-Timestamp']
    nonce     = request.headers['X-Nonce']
    signature = request.headers['X-Signature']
    body      = request.raw_post

    return render json: { error: 'Missing headers' }, status: :unauthorized if [timestamp, nonce, signature].any?(&:blank?)

    unless valid_timestamp?(timestamp.to_i)
      return render json: { error: 'Stale request' }, status: :unauthorized
    end

    if nonce_used?(nonce)
      return render json: { error: 'Replay attack detected' }, status: :unauthorized
    end

    expected_signature = generate_signature(timestamp, nonce, body)

    unless secure_compare(expected_signature, signature)
      return render json: { error: 'Invalid HMAC signature' }, status: :unauthorized
    end

    mark_nonce_as_used(nonce)
  end

  private

  def hmac_secret
    ENV['API_HMAC_SECRET'] || Rails.application.credentials.hmac_secret
  end

  def generate_signature(timestamp, nonce, body)
    payload = "#{timestamp}#{nonce}#{JSON.parse(body).to_json}"
    OpenSSL::HMAC.hexdigest('SHA256', hmac_secret, payload)
  end

  def valid_timestamp?(ts)
    now = Time.now.to_i
    (now - ts).abs <= 5.minutes.to_i
  end

  def nonce_used?(nonce)
    Rails.cache.read("nonce:#{nonce}").present?
  end

  def mark_nonce_as_used(nonce)
    Rails.cache.write("nonce:#{nonce}", true, expires_in: 5.minutes)
  end

  def secure_compare(a, b)
    ActiveSupport::SecurityUtils.secure_compare(a, b)
  end
end
