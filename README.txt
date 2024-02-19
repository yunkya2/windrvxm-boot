WindrvXM-boot
==============

## 概要

XM6 TypeG などの X680x0 エミュレータには、エミュレータが動作するホストのファイルシステムにアクセスするための
Windrv(WindrvXM) という機能があります。
WindrvXMboot.HDS は、co 氏作の デバイスドライバ WindrvXM.SYS を SCSI HDD ディスクイメージ内に埋め込んで
使えるようにしたものです。
ドライバを SCSI HDD 埋め込みイメージにすることで、以下のようなメリットがあります。

* CONFIG.SYS への WindrvXM.SYS の組み込みが不要
  通常の WindrvWM.SYS はエミュレーション環境の CONFIG.SYS に DEVICE=WindrvXM.SYS という行を追加する必要が
  ありますが、WindrvXMboot.HDS はエミュレータの SCSI ディスクイメージに設定するだけで Windrv が使えるようになります。
* Windrv からの起動が可能
  WindrvXMboot.HDS を起動デバイスに設定すると、起動時の CONFIG.SYS やデバイスドライバ読み込みをすべて Windrv 上の
  ファイルから行うことができるようになります。
  エミュレータ XEiJ のホストファイルシステムと同様の機能が XM6 TypeG でも利用できるようになります。

## 使い方

* XM6 TypeG をインストールします。インストール時には SCSI-ROM も用意して SCSI デバイスが利用できるようにしてください。
* WindrvXMboot.HDS を適当なディレクトリに置き、XM6 の ツール - オプション(O) の SCSI タブの「SCSIディスク」に
  イメージファイルとして設定します。
* 「Windrv」タブの「ホスト側とのファイル共有」にチェックを入れ、「リモートドライブ」にWindows 側共有フォルダのパス名を設定します。
* XM6 のエミュレーション環境をリセットすると Human68k が起動します。設定した SCSI ディスクイメージからの起動であれば Windrv 内の
  CONFIG.SYS を使って起動を行います。他のデバイスから起動した場合も、Windrv が使えるようになっています。


URL: https://github.com/yunkya2/windrvxm-boot
Yuichi Nakamura (GitHub: @yunkya2)
