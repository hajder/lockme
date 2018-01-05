module Lockme
  module SignedRequest
    def self.perform(method, path, data = nil)
      headers = signature(method.upcase, path.gsub(/^\//, ''), data)
      params = {
        body: data,
        headers: headers,
        debug_output: Lockme.logger
      }.delete_if {|k,v| k.nil? || v.nil? }

      resp = Request.send(method.downcase, path, params).parsed_response
      if resp.is_a?(Hash) && resp['error']
        raise Lockme::Error.new(resp['error'])
      end
      resp
    rescue JSON::ParserError
      raise Lockme::Error.new('Invalid response from the server')
    end

    def self.signature(*args)
      sha1 = Digest::SHA1.hexdigest([
        *args,
        Lockme.api_secret
      ].compact.join(''))

      {
        'Partner-Key' => Lockme.api_key,
        'Signature'   => sha1
      }
    end
  end

  module Request
    include ::HTTParty

    HEADERS = {
      'User-Agent'    => 'Ruby.Lockme.Api',
      'Accept'        => 'application/json',
      'Content-Type'  => 'application/json'
    }
    API_VERSION = '1.1'

    base_uri "https://lockme.pl/api/v#{API_VERSION}/"
    headers HEADERS
    format :json

    extend Forwardable
    def_delegators 'self.class', :delete, :get, :post, :put
  end
end
