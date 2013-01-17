# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "utils"))

module ::Plugin::Mikustore
  class PluginsList < Gtk::CRUD

    attr_reader :packages

    attr_accessor :filter_entry

    def initialize
      super
      set_model(Gtk::TreeModelFilter.new(model))
      model.set_visible_func{ |model, iter|
        if defined?(@filter_entry) and @filter_entry
          iter[2].to_s.include?(@filter_entry.text)
        else
          true end }
      model.set_modify_func(String, &self.class.modify_func)
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
            iter = model.model.append
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
      ].freeze end

    def self.modify_func
      lambda{ |model, iter, column|
        iter[1] } end

  end
end
