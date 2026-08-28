module Sprockets
  module Rails
    module RouteWrapper
      def internal_assets_path?
        path == self.class.assets_prefix
      end

      def internal?
        super || internal_assets_path?
      end
    end
  end
end
