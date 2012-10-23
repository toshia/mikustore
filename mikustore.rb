# -*- coding: utf-8 -*-

require File.expand_path(File.join(File.dirname(__FILE__), "store_frame"))

Plugin.create(:mikustore) do

  settings "みっくストア" do
    add Plugin::Mikustore::StoreFrame.new
  end

end

