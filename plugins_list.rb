# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "utils"))

module ::Plugin::Mikustore
  class PluginsList < Gtk::CRUD

    attr_reader :packages

    def initialize
      super
      packages = {}
      @packages = {}.freeze
      Thread.new{ Plugin.filtering(:mikustore_plugins, []) }.next{ |args|
        p args
        args.first.each{ |package|
          packages[package[:slug].to_sym] = package
          iter = model.append
          iter[0] = Plugin::Mikustore::Utils.installed_version(package[:slug].to_sym, "○", "")
          iter[1] = package[:name]
          iter[2] = package
        }
        @packages = packages.freeze
      }.terminate("パッケージ読み込みエラー")
    end

    def column_schemer
      [{:kind => :text, :widget => :input, :type => String, :label => '導入'},
       {:kind => :text, :widget => :input, :type => String, :label => 'プラグイン名'},
       {:type => Object},
      ].freeze
    end
  end
end
