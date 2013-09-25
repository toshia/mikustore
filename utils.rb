# -*- coding: utf-8 -*-

module Plugin::Mikustore
  module Utils
    extend Utils

    # _slug_ のプラグインがインストールされていればそのバージョンを返す。
    # されていなければnilを返す。
    # されているがバージョンがない場合は空文字を返す。
    # ==== Args
    # [slug] スラッグ
    # [unspecified_case] バージョン番号がない場合の戻り値（デフォルト：""）
    # [notfound_case] プラグインがインストールされていない場合
    # ==== Return
    # インストールされているプラグインのバージョン
    def installed_version(slug, unspecified_case="", notfound_case=nil)
      plugin_dir = ENV["HOME"] + "/.mikutter/plugin/#{slug}/"
      if(File.directory?(plugin_dir) && Plugin.plugin_list.include?(slug))
        plugin = Plugin.__send__(:create, slug)
        if defined? plugin.spec[:version]
          return plugin.spec[:version]
        else
          return unspecified_case
        end
      else
        return notfound_case
      end
    end

    # インストール済みのプラグインに最新版があるかどうかを返す
    # ==== Args
    # [slug] プラグインスラッグ
    # [upstream_version] 最新版
    # ==== Return
    # アップグレード可能なバージョンがあれば真
    def update_exist?(slug, upstream_version)
      installed_version = Plugin::Mikustore::Utils.installed_version(slug.to_sym, nil, nil)
      installed_version and upstream_version and installed_version.split(".") < upstream_version.split(".")
    end

  end
end
