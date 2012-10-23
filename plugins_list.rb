# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "utils"))

module Plugin::Mikustore
  class PluginsList < Gtk::CRUD

    attr_reader :packages

    def initialize
      super
      packages = {}
      packages_dir = File.expand_path(File.join(File.dirname(__FILE__), "packages"))
      Dir.glob(packages_dir + "/*"){ |package_file|
        package = YAML.load_file(package_file).symbolize
        packages[package[:slug]] = package
        iter = model.append
        iter[0] = Plugin::Mikustore::Utils.installed_version(package[:slug], "○", "")
        iter[1] = package[:name]
        iter[2] = package
      }
      @packages = packages.freeze
    end

    def column_schemer
      [{:kind => :text, :widget => :input, :type => String, :label => '導入'},
       {:kind => :text, :widget => :input, :type => String, :label => 'プラグイン名'},
       {:type => Object},
      ].freeze
    end
  end
end
