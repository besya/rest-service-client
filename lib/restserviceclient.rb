require 'rest-client'
require 'json'

module RestServiceClient
  def self.included(base)
    base.extend(ClassMethods)
  end

  attr_accessor :host,
                :serializer,
                :default_headers,
                :default_params,
                :debug

  def initialize(url = nil, serializer = nil, debug = nil)
    @host = url unless url.nil?
    @host = get_host if respond_to?(:get_host) && url.nil?

    @serializer = JsonSerializer
    @serializer = serializer unless serializer.nil?
    @serializer = get_serializer if respond_to?(:get_serializer) && serializer.nil?

    @debug = false
    @debug = debug unless debug.nil?
    @debug = get_debug if respond_to?(:get_debug) && debug.nil?

    @default_headers = {}
    @default_params = {}

    @default_headers = get_default_headers if respond_to? :get_default_headers
    @default_params = get_default_params if respond_to? :get_default_params
  end

  def make_request(http_method, endpoint, payload = {}, headers = {})
    case http_method
      when :get then  RestClient.get(endpoint, headers)
      when :post then RestClient.post(endpoint, payload, headers)
      when :put then RestClient.put(endpoint, payload, headers)
      when :patch then RestClient.patch(endpoint, payload, headers)
      when :delete then RestClient.delete(endpoint)
      else throw Exception.new("Method #{http_method} doesn't supported.")
    end
  end
  private :make_request

  module ClassMethods
    def host(url)
      define_method :get_host, &-> { url }
    end

    def serializer(serializer_class)
      define_method :get_serializer, &-> { serializer_class }
    end

    def headers(default_headers)
      define_method :get_default_headers, &-> { default_headers }
    end

    def params(default_params)
      define_method :get_default_params, &-> { default_params }
    end

    def debug(flag)
      define_method :get_debug, &-> { flag }
    end

    def get(method_name, path = '', options = {})
      add_method :get, method_name, path, options
    end

    def post(method_name, path = '', options = {})
      add_method :post, method_name, path, options
    end

    def put(method_name, path = '', options = {})
      add_method :put, method_name, path, options
    end

    def patch(method_name, path = '', options = {})
      add_method :patch, method_name, path, options
    end

    def delete(method_name, path = '', options = {})
      add_method :delete, method_name, path, options
    end

    private

    # default_params, default_headers, default_payload, serializer
    def add_method(http_method, method_name, path, options)
      define_method method_name do |headers: {}, payload: {}, parameters: {}, **params|
        options_params = options.fetch(:params, {})
        options_headers = options.fetch(:headers, {})
        options_payload = options.fetch(:payload, {})
        serializer = options.fetch(:serializer, @serializer)

        params = @default_params.merge(options_params.merge(params.merge(parameters)))
        headers = @default_headers.merge(options_headers.merge(headers))
        payload = options_payload.merge payload

        uri = path.clone

        params.each_with_object(uri) do |(k, v), p|
          p.sub! ":#{k}", v.to_s
        end

        endpoint = @host + uri

        if @debug
          puts
          puts ' ______'
          puts '|'
          puts "|  #{self.class.name} is processing #{http_method.upcase} request to #{endpoint}"
          puts "|    Headers: #{headers}"
          puts "|    Payload: #{payload}"
        end

        begin
          result = make_request http_method, endpoint, payload, headers
          response = RestServiceClient::Response.new(
            result.code,
            result.headers,
            result.body,
            serializer.deserialize(result.body)
          )
        rescue RestClient::Exception => e
          response = RestServiceClient::ResponseWithError.new(
              e.http_code,
              e.http_headers,
              e.http_body,
              e.http_body,
              e.message
          )
        end

        if @debug
          puts '|'
          puts "|  #{self.class.name} is processing the response on #{http_method.upcase} request to #{endpoint}"
          puts "|    Status: #{response.status}"
          puts "|    Headers: #{response.headers}"
          puts "|    Result: #{response.result}"
          puts "|    Error message: #{response.message}" if response.is_a?(RestServiceClient::ResponseWithError)
          puts '|______'
          puts
        end

        response
      end
    end
  end

  class JsonSerializer
    def self.deserialize(data)
      JSON.parse(data)
    end
  end

  class Response
    attr_reader :status, :headers, :body, :result

    def initialize(status, headers, body, result)
      @status = status
      @headers = headers
      @body = body
      @result = result
    end
  end

  class ResponseWithError < Response
    attr_reader :message
    def initialize(status, headers, body, result, message)
      super(status, headers, body, result)
      @message = message
    end
  end
end
