# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "utils"))

module Plugin::Mikustore
  class Installer
    def initialize(package, *opt)
      kwargs = opt.first || {}
      @plugin = package
      @depends = []
      @plugin_base = kwargs[:plugin_base] || "~/.mikutter/plugin"
      @database = Plugin.filtering(:mikustore_plugins, []).freeze
    end

    def install
      install_git(@plugin).next { |main_file|
        notice "plugin load: #{main_file}"
        Plugin.load_file(main_file, @plugin)
      }.trap { |e|
        puts e
        revert_git(@plugin)
      }
    end

    private

    def analyze_dependency(plugin)
      if @depends.index(plugin[:slug])
        raise "Circular dependency detected."
      end

      if plugin[:depends][:plugin]
        plugin[:depends][:plugin]
        .select{|pl| Plugin.plugin_list.include?(pl[:slug])}
        .select{|pl| @depends.index(depend).nil?}
        .each do |depend|
          @depends << depend
          analyze_dependency(depend)
        end
      end
      @depends << plugin
    end

    def install_git(package)
      Thread.new {
        plugin_dir = File.expand_path(File.join("#{@plugin_base}", package[:slug].to_s))
        Deferred.fail(Exception.new("#{plugin_dir} already exists.")) if FileTest.exist?(plugin_dir)

        if system("git clone #{package[:repository]} #{plugin_dir}")
          File.join(plugin_dir, "#{package[:slug]}.rb")
        else
          Deferred.fail($?)
        end
      }
    end

    def revert_git(package)
      plugin_dir = File.expand_path(File.join("#{@plugin_base}", package[:slug].to_s))
      if FileTest.exist?(plugin_dir)
        FileUtils.rm_rf(plugin_dir)
      end
    end
  end
end
