require 'rake'
require 'rake/sprocketstask'
require 'sprockets'
require 'action_view'

module Sprockets
  module Rails
    class Task < Rake::SprocketsTask
      attr_accessor :app

      def initialize(app = nil)
        self.app = app
        super()
      end

      def environment
        if @environment_overridden
          super
        elsif app
          # Use initialized app.assets or force build an environment if
          # config.assets.compile is disabled
          @app_environment ||= app.assets || Sprockets::Railtie.build_environment(app)
        else
          super
        end
      end

      def environment=(environment)
        @environment_overridden = true
        super
      end

      def output
        if @output_overridden
          super
        elsif app
          config = app.config
          File.join(config.paths['public'].first, config.assets.prefix)
        else
          super
        end
      end

      def output=(output)
        @output_overridden = true
        super
      end

      def assets
        if @assets_overridden
          super
        elsif app
          app.config.assets.precompile
        else
          super
        end
      end

      def assets=(assets)
        @assets_overridden = true
        super
      end

      def manifest
        if @manifest_overridden
          super
        elsif app
          @app_manifest ||= Sprockets::Manifest.new(index, output, app.config.assets.manifest)
        else
          super
        end
      end

      def manifest=(manifest)
        @manifest_overridden = true
        super
      end

      def define
        namespace :assets do
          %w( environment precompile clean clobber ).each do |task|
            Rake::Task[task].clear if Rake::Task.task_defined?(task)
          end

          # Override this task change the loaded dependencies
          desc "Load asset compile environment"
          task :environment do
            # Load full Rails environment by default
            Rake::Task['environment'].invoke
          end

          desc "Compile all the assets named in config.assets.precompile"
          task :precompile => :environment do
            with_logger do
              manifest.compile(assets)
            end
          end

          desc "Remove old compiled assets"
          task :clean, %i[keep age] => :environment do |_task, args|
            with_logger do
              keep = Integer(args.keep || self.keep)
              if respond_to?(:age)
                manifest.clean(keep, Integer(args.age || age))
              else
                manifest.clean(keep)
              end
            end
          end

          desc "Remove compiled assets"
          task :clobber => :environment do
            with_logger do
              manifest.clobber
            end
          end
        end
      end
    end
  end
end
