require 'iron_cache'
require 'base64'
require 'action_dispatch/middleware/session/abstract_store'

module ActionDispatch
  module Session
    class IronCache < ActionDispatch::Session::AbstractStore

      def initialize(app, options = {})
        @options = options
        super

        @client = ::IronCache::Client.new(options)
      end

      def options
        @options
      end

      def get_session(env, session_id)
        item = nil
        session_id ||= generate_sid

        with_namespace(session_id, options) do |cache, k|
          item = cache.get(k)
          item = item.value unless item.nil?
        end

        session_data = deserialize_entry(item).value rescue {}

        [session_id, session_data]
      end

      def set_session(env, session_id, session, options)
        with_namespace(session_id, options) do |cache, k|
          cache.put(k, serialize_entry(session, options), options)
        end

        session_id
      end

      def destroy_session(env, session_id, options)
        with_namespace(session_id, options) do |cache, k|
          cache.delete(k)
        end

        generate_sid
      end

      private

      def with_namespace(key, options)
        options[:namespace] ||= 'rails_cache'

        cache_name = options[:namespace]

        yield(@client.cache(cache_name), escape_key(key))
      end

      def escape_key(key)
        ekey = ::Base64.encode64(key)

        if ekey.size > 250
          ekey = "#{key[0, 213]}:md5:#{Digest::MD5.hexdigest(key)}"
        end

        ekey
      end

      def deserialize_entry(raw_value)
        if raw_value
          raw_value = ::Base64.decode64(raw_value) rescue raw_value
          entry = Marshal.load(raw_value) rescue raw_value
          entry.is_a?(ActiveSupport::Cache::Entry) ? entry : ActiveSupport::Cache::Entry.new(entry)
        else
          nil
        end
      end

      def serialize_entry(entry, options)
        if options[:raw]
          if entry.respond_to?(:value)
            entry.value.to_s
          else
            entry.to_s
          end
        else
          ::Base64.encode64 Marshal.dump(entry)
        end
      end

    end
  end
end