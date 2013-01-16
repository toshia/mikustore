# -*- coding: utf-8 -*-

require File.expand_path(File.join(File.dirname(__FILE__), "store_frame"))

Plugin.create(:mikustore) do

  settings "みっくストア" do
    add Plugin::Mikustore::StoreFrame.new
  end

  filter_mikustore_plugins do |plugins|
    Dir[File.expand_path(File.join(File.dirname(__FILE__), "packages", "*"))].each{ |package_file|
      plugins << YAML.load_file(package_file).symbolize
    }
    [plugins]
  end
end

