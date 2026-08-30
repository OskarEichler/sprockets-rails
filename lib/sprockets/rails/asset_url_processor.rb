module Sprockets
  module Rails
    # Resolve assets referenced in CSS `url()` calls and replace them with the digested paths
    class AssetUrlProcessor
      REGEX = /url\(\s*(?:"(?<double_quoted>[^"]*)"|'(?<single_quoted>[^']*)'|(?<unquoted>[^"'\s)]+))\s*\)/
      URI_REFERENCE = /\A(?:\#|\/\/|[a-z][a-z0-9+.-]*:)/i

      def self.call(input)
        context = input[:environment].context_class.new(input)
        data    = input[:data].gsub(REGEX) do |match|
          path = Regexp.last_match.values_at(:double_quoted, :single_quoted, :unquoted).compact.first
          path = path.delete_prefix('./')
          next match if path.empty? || path.match?(URI_REFERENCE)

          "url(#{context.asset_path(path)})"
        end

        context.metadata.merge(data: data)
      end
    end
  end
end
