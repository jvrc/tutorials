インストール
============

この章では Choreonoid とモデルファイルのインストール方法について解説します。
インストールを実行するのは Ubuntu 14.04 x64 版とします。


Choreonoidのインストール
------------------------

端末上で次のコマンドを実行し、Choreonoid と周辺ツールをインストールします。 ::

 sudo add-apt-repository ppa:hrg/daily
 sudo apt-get update
 sudo apt-get install choreonoid openrtm-aist


サンプルファイルの取得
----------------------

このチュートリアルで使用するファイルを取得します。
ファイルの取得にあたってはgitコマンドが必要です。Ubuntu 環境では以下のコマンドでgitをインストールできます。 ::

 sudo apt-get install git

サンプルファイルのリポジトリは以下のコマンドを実行することで取得できます。 ::

 git clone https://github.com/jvrc/samples

これによってサンプルファイルのリポジトリを格納した "samples" というディレクトリが生成されます。

モデルファイルのインストール
----------------------------

モデルファイルはJVRC公式HP上で公開されているJVRC-1のモデルを使用します。次のページからダウンロードし、ダウンロードしたファイルを適当なディレクトリに展開して下さい。

  https://jvrc.org/download.html


