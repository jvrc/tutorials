Connecting a RT component
=========================


This section explains how to connect Choreonoid and a RT component by developing an example component which read joint angles.

コントローラの雛形作成
----------------------

RTCBuilderを使ってコントローラのソースコードの雛形を作成します。

RTCBuilderの起動
################

以下を実行してRTCBuilder(OpenRTP, Eclipseベース)を起動します。

.. code-block:: bash

 $ openrtp

初めて起動した場合、またはデフォルトのワークスペースの場所を設定していない場合は次のようなダイアログが表示されます。

.. image:: images/openrtp_make_workspace.png

Eclipseでは、各種作業を行うフォルダを「ワークスペース」(Work Space)とよび、原則としてすべての生成物はこのフォルダの下に保存されます。ワークスペースはアクセスできるフォルダであれば、どこに作っても構いませんが、このチュートリアルでは「/home/<ユーザ名>/workspace」をワークスペースとしますのでそのままOKボタンを押してください。

初めて起動した場合は以下のようなWelcomeページが表示されますので、左上の「×」ボタンを押して閉じてください。 

.. image:: images/openrtp_welcome.png

次のような画面が表示されます（前回終了時の状態に依存するため表示される画面は異なる場合があります）。

.. image:: images/openrtp_init_screen.png

右上の「パースペクティブを開く」ボタンを押し、プルダウンの「その他(O)…」ボタンを押します。

.. image:: images/openrtp_open_perspective.png

「パースペクティブを開く」ダイアログが表示されるので、「RTC Builder」を選択してOKボタンを押すことで、RTCBuilderが起動します。メニューバーに「カナヅチとRT」のRTCBuilderのアイコンが現れます。

.. note::

  RTCBuilderを起動する際に以下のエラーが生じることがあります。

  .. code-block:: bash

    パースペクティブ 'jp.go.aist.rtm.rtcbuilder.ui.perspective' のオープンで問題が発生しました。
  
  RTCBuilderを起動した端末には以下のメッセージが出ているかと思います。
   
  .. code-block:: bash

    java.io.IOException: Couldn't get lock for rtcbuilder%u.log

  既知のバグが影響している可能性があるので、対処方法として以下を行ってください。

  * logger.properties ファイルを作成して以下のようにログファイルパターンを記載しておく。

    .. code-block:: bash

     jp.go.aist.rtm.rtcbuilder.RTCBLogHandler.pattern=%h/.rtcb%u.log
     jp.go.aist.rtm.systemeditor.RTSELogHandler.pattern=%h/.rtse%u.log

  * 起動時のオプションでこのファイルをロガークラスのコンフィギュレーションとして読み込ませて"openrtp"を起動する。

    .. code-block:: bash

     $ openrtp -vmargs -Djava.util.logging.config.file=$HOME/workspace/logger.properties

新規プロジェクトの作成
######################

RTコンポーネントを作成するために、RTCBuilderで新規プロジェクトを作成する必要が有ります。プロジェクトを作成する方法は2種類あります。

1. 画面上部のメニューから[ファイル]－[新規]－[プロジェクト]を選択 (Eclipse共通)

   * 「新規プロジェクト」画面において，[その他]－[RTC Builder]を選択し、[次へ]をクリック
   
     .. image:: images/openrtp_new_project.png

2. メニューバーの「RTCBuilder」のアイコンをクリック

どちらの方法でも、次のようなプロジェクト作成ウィザードが開始されます。「プロジェクト名」欄に作成するプロジェクト名(ここでは"RobotControllerRTC")を入力して「完了」を押します。

.. image:: images/openrtp_make_project.png

指定した名称のプロジェクトが生成され、パッケージエクスプローラ内に追加されます。

生成したプロジェクト内には、デフォルト値が設定されたRTCプロファイルXML(RTC.xml)が自動的に生成されます。

.. RTCプロファイルエディタの起動
.. #############################

プロファイル情報入力とコードの生成
##################################

RTCBuilderのエディタで、いちばん左の「基本」タブを選択し、基本情報を入力します。RTコンポーネントの仕様(名前)の他に、概要やバージョン等を入力します。ラベルが赤字の項目は必須項目です。その他はデフォルトで構いません。

===================  ==========================
モジュール名:        RobotControllerRTC
モジュール概要:      Robot Controller component
バージョン:          1.0.0
ベンダ名:            AIST
モジュールカテゴリ:  Generic
コンポーネント型:    STATIC
アクティビティ型:    PERIODIC
コンポーネント種類:  DataFlow
最大インスタンス数:  1
実行型:              PeriodicExecutionContext
実行周期:            1000.0
===================  ==========================

.. image:: images/rtcbuilder_basic.png

次に「アクティビティ」タブを選択し、使用するアクションコールバックを指定します。

本コンポーネントでは、onActivated(), onDeactivated(), onExecute() コールバックを使用します。下図のように(1)コールバックをクリック後に(2)のラジオボタン"ON"にチェックを入れます。使用するコールバックごとに同様の手順で"ON"にしていきます。

.. image:: images/rtcbuilder_activity.png

さらに、「データポート」タブを選択し、データポートの情報を入力します。 以下のように入力します。なお、変数名や表示位置はオプションなのでデフォルトのままで構いません。

* InPort プロファイル:

  =========  ==========================
  ポート名:  q
  データ型:  RTC::TimeDoubleSeq
  変数名:    angle
  表示位置:  LEFT
  =========  ==========================

* OutPort プロファイル:

  なし
  
.. image:: images/rtcbuilder_dataport.png

次に、「言語・環境」タブを選択し、プログラミング言語を選択します。 ここでは、「C++」を選択します。なお、言語・環境はデフォルト等が設定されておらず、指定し忘れるとコード生成時にエラーになりますので、必ず言語の指定を行うようにしてください。

.. また、C++の場合デフォルトではCMakeを利用してビルドすることになっていますが、旧式のVCのプロジェクトやソリューションを直接RTCBuilderが生成する方法を利用したい場合は Use old build environment をチェックしてください。

.. image:: images/rtcbuilder_lang.png

最後に、「基本」タブにある「コード生成」ボタンをクリックし、コンポーネントの雛型を生成します。

.. image:: images/rtcbuilder_basic_generate.png

※ 生成されるコード群は、eclipse起動時に指定したワークスペースフォルダの中に生成されます。現在のワークスペースは、「ファイル(F)」 > 「ワークスペースの切り替え(W)...」で確認することができます。

.. 仮ビルド
.. ########
.. 
.. さて、ここまででRTコンポーネントのソースコードの雛形が生成されました。処理の中身は実装されていないので、InPortに入力があっても何も出力されませんが、生成直後のソースコードだけでもコンパイルおよび実行は可能です。
.. 
.. ※サービスポートとプロバイダを持つコンポーネントの場合、実装を行わないとビルドが通らないものもあります。
.. 
.. では、まずCMakeを利用してビルド環境のConfigureを行います。RTコンポーネントのソースが生成されたディレクトリで以下を実行すると、Configureおよびビルドが完了するはずです。
.. 
.. .. code-block:: bash
.. 
..  $ cd $HOME/workspace/RobotControllerRTC
..  $ mkdir build
..  $ cd build
..  $ cmake ..
..  $ make
.. 
.. ビルド終了後、空のRobotControllerRTCCompを起動してみましょう。
.. 
.. 起動後、RTSystemEditorなどでアクセスしてみてください。RobotControllerRTC0というコンポーネントが表示されているはずです。
.. 

コントローラのソースコード
--------------------------

コード作成操作により、コントローラのソースコード一式がワークスペース内の領域「$HOME/workspace/RobotControllerRTC/」に生成されます（生成済みのソースコードをsamples/tutorials/rtc/RobotControllerRTC0に収録しています）。

コントローラのヘッダファイル
############################

コントローラのヘッダファイルは以下になります。

  $HOME/workspace/RobotControllerRTC/include/RobotControllerRTC.h

※ 一部のコメント行は除去しています。

.. code-block:: cpp
   :linenos:

   /*!
    * @file  RobotControllerRTC.h
    * @brief Robot Controller component
    * @date  $Date$
    *
    * $Id$
    */
   
   #ifndef ROBOTCONTROLLERRTC_H
   #define ROBOTCONTROLLERRTC_H
   
   #include <rtm/idl/BasicDataTypeSkel.h>
   #include <rtm/idl/ExtendedDataTypesSkel.h>
   #include <rtm/idl/InterfaceDataTypesSkel.h>
   
   using namespace RTC;
   
   #include <rtm/Manager.h>
   #include <rtm/DataFlowComponentBase.h>
   #include <rtm/CorbaPort.h>
   #include <rtm/DataInPort.h>
   #include <rtm/DataOutPort.h>
   
   class RobotControllerRTC
     : public RTC::DataFlowComponentBase
   {
     public:
       RobotControllerRTC(RTC::Manager* manager);
       ~RobotControllerRTC();
       virtual RTC::ReturnCode_t onInitialize();
       virtual RTC::ReturnCode_t onActivated(RTC::UniqueId ec_id);
       virtual RTC::ReturnCode_t onDeactivated(RTC::UniqueId ec_id);
       virtual RTC::ReturnCode_t onExecute(RTC::UniqueId ec_id);
   
    protected:
      RTC::TimedDoubleSeq m_angle;
      InPort<RTC::TimedDoubleSeq> m_angleIn;
   
    private:
   
   };
   
   extern "C"
   {
     DLL_EXPORT void RobotControllerRTCInit(RTC::Manager* manager);
   };
   
   #endif // ROBOTCONTROLLERRTC_H

今回、ヘッダファイルは変更しません。

RTC::TimedDoubleSeq というのは、時刻情報とdouble型の実際の値を持つOpenRTM固有の複合型です。
SeqはOpenRTMにおける配列型のように扱います。
OpenRTMにおけるdouble[]型と考えておけばよいでしょう。

InPort<RTC::TimedDoubleSeq> はRTCの入力ポートを表す型であり、入力ポートを操作するにはこれを利用します。
m_angleは入力ポートから関節角度を受けとるための変数です。
m_angleInで取得した値はm_angleで参照します。

コントローラのソースコード
##########################

コントローラのソースコードは以下になります。

  $HOME/workspace/RobotControllerRTC/src/RobotControllerRTC.cpp

※ 一部のコメント行は除去しています。

.. code-block:: cpp
   :linenos:

   /*!
    * @file  RobotControllerRTC.cpp
    * @brief Robot Controller component
    * @date $Date$
    *
    * $Id$
    */
   
   #include "RobotControllerRTC.h"
   
   // Module specification
   static const char* robotcontrollerrtc_spec[] =
     {
       "implementation_id", "RobotControllerRTC",
       "type_name",         "RobotControllerRTC",
       "description",       "Robot Controller component",
       "version",           "1.0.0",
       "vendor",            "AIST",
       "category",          "Generic",
       "activity_type",     "PERIODIC",
       "kind",              "DataFlowComponent",
       "max_instance",      "1",
       "language",          "C++",
       "lang_type",         "compile",
       ""
     };
   
   RobotControllerRTC::RobotControllerRTC(RTC::Manager* manager)
     : RTC::DataFlowComponentBase(manager),
       m_angleIn("q", m_angle)
   {
   }
   
   RobotControllerRTC::~RobotControllerRTC()
   {
   }
   
   RTC::ReturnCode_t RobotControllerRTC::onInitialize()
   {
     addInPort("q", m_angleIn);
     
     return RTC::RTC_OK;
   }
   
   RTC::ReturnCode_t RobotControllerRTC::onActivated(RTC::UniqueId ec_id)
   {
     return RTC::RTC_OK;
   }
   
   RTC::ReturnCode_t RobotControllerRTC::onDeactivated(RTC::UniqueId ec_id)
   {
     return RTC::RTC_OK;
   }
   
   RTC::ReturnCode_t RobotControllerRTC::onExecute(RTC::UniqueId ec_id)
   {
     return RTC::RTC_OK;
   }
   
   extern "C"
   {
    
     void RobotControllerRTCInit(RTC::Manager* manager)
     {
       coil::Properties profile(robotcontrollerrtc_spec);
       manager->registerFactory(profile,
                                RTC::Create<RobotControllerRTC>,
                                RTC::Delete<RobotControllerRTC>);
     }
     
   };

コントローラのビルド
--------------------

コントローラの雛形が生成されましたので、この段階で一度ビルドできることを確認します。ビルドするにはRTコンポーネントのソースファイル一式が生成されたディレクトリで以下を実行します。

.. code-block:: bash

 $ cd $HOME/workspace/RobotControllerRTC
 $ mkdir build
 $ cd build
 $ cmake ..
 $ make

コントローラの実装
------------------

生成されたのはコントローラの雛形で、このまま実行しても何も処理が行われません。onExecute() コールバックなどに処理を記述します。このチュートリアルでは関節角度を読みとって標準出力に表示する処理を実装します。

実装したソースコードは以下の通りです（一部コメントは削除しています）。追記した部分をハイライトしています。
（編集済みのファイルをsamples/tutorials/rtc/RobotControllerRTC1/src/RobotControllerRTC.cppに収録しています）


.. code-block:: cpp
   :linenos:
   :emphasize-lines: 11-13,63-69

   // -*- C++ -*-
   /*!
    * @file  RobotControllerRTC.cpp
    * @brief Robot Controller component
    * @date $Date$
    *
    * $Id$
    */
   
   #include "RobotControllerRTC.h"
   #include <iostream>
   
   using namespace std;
   
   // Module specification
   static const char* robotcontrollerrtc_spec[] =
     {
       "implementation_id", "RobotControllerRTC",
       "type_name",         "RobotControllerRTC",
       "description",       "Robot Controller component",
       "version",           "1.0.0",
       "vendor",            "AIST",
       "category",          "Generic",
       "activity_type",     "PERIODIC",
       "kind",              "DataFlowComponent",
       "max_instance",      "1",
       "language",          "C++",
       "lang_type",         "compile",
       ""
     };
   
   RobotControllerRTC::RobotControllerRTC(RTC::Manager* manager)
     : RTC::DataFlowComponentBase(manager),
       m_angleIn("q", m_angle)
   {
   }
   
   RobotControllerRTC::~RobotControllerRTC()
   {
   }
   
   RTC::ReturnCode_t RobotControllerRTC::onInitialize()
   {
     addInPort("q", m_angleIn);
     
     return RTC::RTC_OK;
   }
   
   RTC::ReturnCode_t RobotControllerRTC::onActivated(RTC::UniqueId ec_id)
   {
     return RTC::RTC_OK;
   }
   
   
   RTC::ReturnCode_t RobotControllerRTC::onDeactivated(RTC::UniqueId ec_id)
   {
     return RTC::RTC_OK;
   }
   
   
   RTC::ReturnCode_t RobotControllerRTC::onExecute(RTC::UniqueId ec_id)
   {
     if(m_angleIn.isNew()){
       m_angleIn.read();
     }
   
     for(size_t i=0; i < m_angle.data.length(); ++i){
       cout << "m_angle.data[" << i << "] is " << m_angle.data[i] << std::endl;
     }
   
     return RTC::RTC_OK;
   }
   
   extern "C"
   {
    
     void RobotControllerRTCInit(RTC::Manager* manager)
     {
       coil::Properties profile(robotcontrollerrtc_spec);
       manager->registerFactory(profile,
                                RTC::Create<RobotControllerRTC>,
                                RTC::Delete<RobotControllerRTC>);
     }
     
   };

onExecute()はRTCの実行中に定期的に呼ばれます。
ここで関節角度を取得し標準出力に表示する処理を行います。
m_angleIn.isNew()とは新しいデータが到着しているか確認する関数です。
onExecute()の実行時にはデータが到着しているかどうかが分からないので、ここでチェックしています。
新しいデータが来ていた場合にはm_angleIn.read()でデータを読み込みます。
読み込んだデータは自動的にm_angleに格納され、m_angle.dataとして取得できます。
m_angle.dataは各関節毎に配列の値となっています。

コントローラのインストール
--------------------------

RTコンポーネントの実装が終わったら、makeコマンドを実行して再度ビルドを行います。ビルドに成功するとRTCコントローラモジュール「src/RobotControllerRTC.so」が生成されるので、以下を実行してインストールします。

.. code-block:: bash 

 $ sudo mkdir -p /usr/lib/choreonoid-1.5/rtc
 $ sudo cp -p src/RobotControllerRTC.so /usr/lib/choreonoid-1.5/rtc

.. note::
   
  Choreonoidでは読み込むRTCコントローラのモジュールは、Choreonoidのインストール先の共有ディレクトリ(/usr/lib/choreonoid-1.5/rtc)に配置するか、BodyRTCのプロパティで指定する際に絶対パスで指定する必要があります。


Open a project file
-------------------

Choreonoid を起動します。

.. code-block:: bash

 $ choreonoid

Open a project file by choosing "Open Project" menu of "File" menu. The file name is samples/tutorials/cnoid/sample1.cnoid.

Add a controller
----------------

Select "JVRC" first in the item view.
Then create a BodyRTC item by choosing "BodyRTC" menu followed by "File", "New..." menus. 

BodyRTCを作成することにより、シミュレーション世界に存在するロボットが1つのRTコンポーネントとなり、データポートを介してセンサ情報の取得やアクチュエータに対する指令を送信することができるようになります。

コントローラの設定
------------------

プロジェクト上でRTコンポーネント(RTC)を作成しただけでは、ロボットの制御を行うことができません。

Choreonoidの操作画面に戻って、アイテムビューで「BodyRTC」を選択するとプロパティのタブ(プロパティビューと言います)にRTCの設定が表示されます。プロパティビューの「コントローラのモジュール名」を「RobotControllerRTC」とします。これは「コントローラのビルド」で作成したモジュールのパスと対応しています。さらに、プロパティビューの「自動ポート接続」を true にします。このプロパティがtrueの場合、BodyRTCとコントローラとして指定されたRobotControllerRTCのデータポートのうち、名称が同じポートについて自動的にポートの接続が行われます。

.. image:: images/property_rtc.png

「設定モード」プロパティが「標準ポートを作成」になっていますが、この場合、標準的なデータポート（カメラ、レンジセンサを除くセンサに対応する出力ポート、関節角度列の出力ポート、関節トルクの入力ポート）が自動的に生成されます。これをRTSystemEditorを使って確認してみましょう。次のコマンドを実行してOpenRTPを起動します。

.. code-block:: bash

 $ openrtp

必要に応じてワークスペースの指定を行い、RTCBuilderの時と同じ手順でRTSystemEditorパースペックティブを開きます。以下のような画面となるはずです。

.. image:: images/openrtp_rtse.png

画面左にあるName Service Viewにネームサーバに登録されている情報が表示されます。「127.0.0.1」の左にある黒い三角印をクリックするとツリーを展開することができます。ツリーを展開すると「JVRC|rtc」というアイテムがあるはずです。

.. image:: images/openrtp_name_service_view.png

ツールバーにある「ON」と書かれたアイコンをクリックし、System Diagramを生成します。続いてName Service Viewに表示された「JVRC|rtc」をドラッグし、System Diagramにドロップすると次のようなRTCが表示され、センサに対応するデータポートや関節トルクの指令を入力するためのデータポートが生成されていることがわかります。

.. image:: images/openrtp_rtc.png


シミュレーションを実行する
--------------------------

シミュレーションツールバーの「シミュレーション開始ボタン」を押します。シミュレーションを実行するとChoreonoidを実行している端末に関節角度(m_angle)の値が表示されるはずです。

.. image:: images/output.png

またRTSystemEditorのName Service ViewからRobotControllerRTC0|rtcもSystem Diagramにドラッグアンドドロップすると、2つのRTCが次の図のように接続されていることが確認できます。2つのRTCはともに「q」という名前がついたデータポートを持っているために、自動ポート接続機能によって自動的に接続されています。

.. image:: images/openrtp_sample2.png

このようにして得られる関節角度を基にトルクをロボットに入力することでロボットの制御を行うことができます。この後のサンプルで詳しく解説します。

プロジェクトの保存
------------------
シミュレーションの実行が終わったら、プロジェクトを保存しておきましょう。[ファイル]-[名前を付けてプロジェクトを保存]を選択し、ファイル名をsample2.cnoidとして保存します。

A sample project used in this tutorial
--------------------------------------

You can find a sample project file created by this tutorial in samples/tutorials/cnoid/sample2.cnoid.

.. toctree::
   :maxdepth: 2
