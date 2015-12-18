Install
=======

This chapter explains how to install a software package, download a mode and sample files used in the tutorials. The verion of OS used in the tutorials is Ubuntu 14.04LTS(64bit).

.. note::
   
  Choreonoidを動かすPCは、高性能なGPUを搭載しているに越したことはありませんが、最近のIntelチップセット内蔵GPUでもそれなりに動作します。

.. note::

  VMware, VirtualBox, Parallels 等の仮想マシンは、3Dグラフィックス周りの互換性が不十分なため、基本的には動作しますが一部機能が正常に動作しない場合があります。

.. note::

  nVIDIAのドライバはオープンソース版ではなくプロプライエタリ版を使用することを推奨します。
  

Installation of Choreonoid
--------------------------

Execute the following commands in gnome-terminal. Chorenoid and required packages are installed.

.. code-block:: bash

 $ sudo add-apt-repository ppa:hrg/daily
 $ sudo apt-get update
 $ sudo apt-get install choreonoid libcnoid-dev openrtm-aist openrtm-aist-dev doxygen hrpsys-base libav-tools cmake

.. note:: GIOPメッセージサイズの変更

  ポリゴン数の多いモデルやポイントクラウド等大きなデータを通信する場合、設定値よりも大きいと通信されないため、giopMaxMsgSize パラメータの値を大きな値に変更しておく必要があります。デフォルト値は2MBですが、例えば以下のように200MBに設定します。
  
  .. code-block:: bash

    $ sudo vi /etc/omniORB.cfg
    giopMaxMsgSize = 209715200     ＃ 200MB に設定


Downloading sample files
------------------------

Download sample files used in the tutorials. Git command is used to download the files. Git command can be installed by the next command.

.. code-block:: bash

 $ sudo apt-get install git

The sample files can be downloaded by the next command.

.. code-block:: bash

 $ git clone https://github.com/jvrc/samples

"samples" directory created by the command above contains a git repository for sample files.

JVRC-1のモデル、JVRCのタスクモデルの取得
----------------------------------------

本チュートリアルではJVRC(www.jvrc.org)で使用されたヒューマノイドロボットJVRC-1のモデル、JVRC本競技時のタスクモデル（競技環境のモデル）を使用します。これらのモデルは以下のコマンドを実行することで取得できます。

.. code-block:: bash

 $ git clone https://github.com/jvrc/model

サンプルファイルのいくつかがJVRC-1のモデルを相対パスで参照しているため、以下のようにシンボリックリンクを張っておきます。

.. code-block:: bash

 $ cd samples/tutorials
 $ ln -s ../../model/JVRC-1 .

OpenRTPのインストール
------------------------

以下のページを参考に OpenRTP (Open RT Platform) をインストールして下さい。

  http://www.openrtm.org/openrtm/ja/node/5778

