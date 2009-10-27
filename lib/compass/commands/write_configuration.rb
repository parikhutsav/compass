require 'compass/commands/project_base'

module Compass
  module Commands
    module ConfigurationOptionsParser
      def set_options(opts)
        opts.banner = %Q{
          Usage: compass config [path/to/config_file.rb] [options]

          Description:
            Generate a configuration file for the options specified.
            Compass will recognize configuration files in the
            following locations relative to the project root:
              * #{Compass::Configuration::Helpers::KNOWN_CONFIG_LOCATIONS.join("
              * ")}
            Any other location, and you'll need to specify it when working with the command line tool using the -c option.

          Options:
        }.strip.split("\n").map{|l| l.gsub(/^ {0,10}/,'')}.join("\n")

        super
      end
    end
    class WriteConfiguration < ProjectBase

      register :config

      include InstallerCommand

      def initialize(working_path, options)
        super
        assert_project_directory_exists!
      end

      def add_project_configuration
        Compass.add_project_configuration
      end

      def perform
        directory projectize(File.dirname(options[:configuration_file]))
        installer.write_configuration_files(options[:configuration_file])
      end

      def installer_args
        [nil, project_directory, options]
      end

      def explicit_config_file_must_be_readable?
        false
      end

      class << self

        def option_parser(arguments)
          parser = Compass::Exec::CommandOptionParser.new(arguments)
          parser.extend(Compass::Exec::GlobalOptionsParser)
          parser.extend(Compass::Exec::ProjectOptionsParser)
          parser.extend(ConfigurationOptionsParser)
        end

        def usage
          option_parser([]).to_s
        end

        def description(command)
          "Generate a configuration file for the provided command line options."
        end

        def parse!(arguments)
          parser = option_parser(arguments)
          parser.parse!
          parse_arguments!(parser, arguments)
          parser.options
        end

        def parse_arguments!(parser, arguments)
          if arguments.size == 1
            parser.options[:configuration_file] = arguments.shift
          elsif arguments.size == 0
            # default to the current directory.
          else
            raise Compass::Error, "Too many arguments were specified."
          end
        end

      end

    end
  end
end
