# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "utils"))

module ::Plugin::Mikustore
  class PluginsList < Gtk::CRUD

    attr_reader :packages

    def initialize
      super
      @packages = {}.freeze
      reload
    end

    def reload
      packages = @packages.dup
      self.sensitive = false
      Thread.new{ Plugin.filtering(:mikustore_plugins, []) }.next{ |args|
        args.first.each{ |package|
          if not packages.has_key? package[:slug].to_sym
            packages[package[:slug].to_sym] = package
            iter = model.append
            iter[0] = Plugin::Mikustore::Utils.installed_version(package[:slug].to_sym, "○", "")
            iter[1] = package[:name]
            iter[2] = package end }
        @packages = packages.freeze
        self.sensitive = true
      }.terminate("パッケージ読み込みエラー").trap{
        self.sensitive = true
      }
    end

    def column_schemer
      [{:kind => :text, :widget => :input, :type => String, :label => '導入'},
       {:kind => :text, :widget => :input, :type => String, :label => 'プラグイン名'},
       {:type => Object},
      ].freeze
    end
  end
end
