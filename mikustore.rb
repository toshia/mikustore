# -*- coding: utf-8 -*-

require File.expand_path(File.join(File.dirname(__FILE__), "store_frame"))

Plugin.create(:mikustore) do
  store_frame = nil

  settings "みっくストア" do
    store_frame = Plugin::Mikustore::StoreFrame.new
    add store_frame
  end

  on_mikustore_plugin_installed do |slug|
    if store_frame and not store_frame.destroyed?
      store_frame.packages.reload
    end
  end

  filter_mikustore_plugins do |plugins|
    Dir[File.expand_path(File.join(File.dirname(__FILE__), "packages", "*"))].each{ |package_file|
      plugins << YAML.load_file(package_file).symbolize
    }
    [plugins]
  end
end

