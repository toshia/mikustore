# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "utils"))
require File.expand_path(File.join(File.dirname(__FILE__), "installer"))

module Plugin::Mikustore
  class PluginDetail < Gtk::VBox

    attr_reader :plugin_name, :description, :requirements, :install_button, :uninstall_button, :latest_version, :author
    attr_reader :requirement_mikutter, :requirement_plugin
    attr_reader :package

    def initialize
      super
      @package = nil
      @plugin_name = Gtk::Label.new
      @description = Gtk::IntelligentTextview.new
      @latest_version = Gtk::Label.new
      @author = Gtk::HBox.new
      @requirements = Gtk::Table.new(2, 2)
      @install_button = Gtk::Button.new("インストール")
      @uninstall_button = Gtk::Button.new("アンインストール")
      @requirement_mikutter = Gtk::Label.new
      @requirement_plugin = Gtk::Label.new
      @requirements.
        attach(caption("mikutterのバージョン").left, 0, 1, 0, 1).
        attach(caption("依存するプラグイン").left, 0, 1, 1, 2).
        attach(@requirement_mikutter.left, 1, 2, 0, 1).
        attach(@requirement_plugin.left, 1, 2, 1, 2).
        set_row_spacing(0, 4).
        set_row_spacing(1, 4).
        set_column_spacing(0, 16)
      @install_button.ssc(:clicked) {
        install_package {
          @install_button.sensitive = false
        }
        true }
      @install_button.sensitive = false
      @uninstall_button.ssc(:clicked) {
        if Gtk::Dialog.confirm("プラグインのファイルも削除されますが，本当にアンインストールしますか？")
          uninstall_package
        end
        true
      }
      @uninstall_button.sensitive = false

      requirements_group = Gtk::Frame.new.set_border_width(8)
      requirements_group.set_label_widget(caption("依存関係"))

      closeup @plugin_name
      closeup @description
      closeup Gtk::HBox.new.closeup(caption("最新バージョン")).add(@latest_version)
      closeup requirements_group.add(@requirements)
      closeup Gtk::VBox.new.closeup(caption("開発者").left).closeup(@author)
      closeup @install_button
      closeup @uninstall_button
    end

    # パッケージが選択された時。画面を書き換える
    def set_package(new_package)
      type_strict new_package => Hash
      @package = new_package
      plugin_name.set_markup("<span size=\"x-large\" weight=\"bold\">#{package[:name]}</span>")
      description.rewind(package[:description])
      latest_version.set_text((package[:version] || "なし").to_s)
      requirement_mikutter.set_text(package[:depends][:mikutter].to_s)
      if(package[:depends][:plugin])
        requirement_plugin.set_text(package[:depends][:plugin].join(","))
      else
        requirement_plugin.set_text("指定なし")
      end
      set_button_state
      author.children.each{ |c| author.remove(c) }
      author_box = Gtk::HBox.new(false, 4)
      author.add(author_box)
      Thread.new{ User.findbyidname(package[:author]) }.next{ |user|
        if not author_box.destroyed?
          author_box.closeup Gtk::WebIcon.new(user[:profile_image_url], 32, 32)
          author_box.add Gtk::IntelligentTextview.new("@#{user[:idname]} #{user[:name]}\n#{user[:statuses_count]} tweets, #{user[:favourites_count]}favs")
          author_box.show_all
        end
      }.terminate("ユーザ #{package[:author]} の情報を取得できませんでした")
    end
    alias :package= :set_package

    private

    def set_button_state
      if Plugin::Mikustore::Utils.installed_version(package[:slug].to_sym)
        install_button.sensitive = false
        install_button.set_label("インストール")
        uninstall_button.sensitive = true
        uninstall_button.set_label("アンインストール")
      else
        install_button.sensitive = true
        install_button.set_label("インストール")
        uninstall_button.sensitive = false
        uninstall_button.set_label("アンインストール") end
    end

    def install_package
      installer = Installer.new(package)
      if installer.valid
        install_button.sensitive = false
        install_button.set_label("インストール中")
        installer.install.next{
          set_button_state
          Plugin.call(:mikustore_plugin_installed, package[:slug])
        }.trap {
          Gtk::Dialog.alert("プラグインのインストールに失敗しました．")
          set_button_state
        }
      else
        Gtk::Dialog.alert("依存関係の解析に失敗しました．\n循環参照か解決できない依存があります．")
      end
    end

    def uninstall_package
      Plugin.uninstall(package[:slug])
      plugin_dir = File.expand_path("~/.mikutter/plugin/#{package[:slug]}/")
      if FileTest.exist?(plugin_dir)
        FileUtils.rm_rf(plugin_dir) end
      set_button_state
    end

    def caption(text)
      Gtk::Label.new.set_markup("<b>#{text}</b>")
    end
  end
end

