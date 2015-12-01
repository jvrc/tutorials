Install
=======

This chapter explains how to install a software package, download a mode and sample files used in the tutorials. The verion of OS used in the tutorials is Ubuntu 14.04LTS(64bit).

.. note::
   
  Choreonoidを動かすPCは、高性能なGPUを搭載しているに越したことはないが、最近のIntelチップセット内蔵GPUでもそれなりに動作する。

.. note::

  VMware, VirtualBox, Parallels 等の仮想マシンは、3Dグラフィックス周りの互換性が不十分なため、動作するが支障が生じる場合がある。

.. note::

  nVIDIAのドライバはオープンソース版ではなくプロプライエタリ版を使用するとよい。(Ubuntuなど)
  

Installation of Choreonoid
--------------------------

Execute the following commands in gnome-terminal. Chorenoid and required packages are installed.

.. code-block:: bash

 $ sudo add-apt-repository ppa:hrg/daily
 $ sudo apt-get update
 $ sudo apt-get install choreonoid libcnoid-dev openrtm-aist openrtm-aist-dev doxygen hrpsys-base

.. note:: GIOPメッセージサイズの変更

  ポリゴン数の多いモデルやポイントクラウド等大きなデータを通信する場合、設定値よりも大きいと通信されないため、giopMaxMsgSize パラメータの値を変更するとよい。
  
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

Downloading a model file
------------------------

Let's use a model file of JVRC-1 which is available on the official website of JVRC. Please download the model file from the follwing webpage and extract the file under samples/tutorials.

  https://jvrc.org/download.html

