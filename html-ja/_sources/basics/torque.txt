Joint control using a RT component
==================================


This section extentds the RT component developed in the previous section to keep the robot standing position.


Open a project file
-------------------

「メニュー」の「プロジェクトの読み込み」から JVRC モデルファイル用のプロジェク
トファイルを読み込みます。プロジェクトファイル名は「サンプルファイルのインス
トール」でダウンロードしたリポジトリの「samples/tutorials/cnoid/sample2.cnoid」です。

Source code of a controller
---------------------------

コントローラのヘッダのソースコードは以下になります。Choreonoidに含まれるサンプルのSR1WalkControllerRTC.hを基にしています。 ::

   /**
      Sample Robot motion controller for the JVRC robot model.
      This program was ported from the "RobotTorqueController.h" sample of Choreonoid.
   */
   
   #ifndef RobotTorqueControllerRTC_H
   #define RobotTorqueControllerRTC_H
   
   #include <rtm/idl/BasicDataTypeSkel.h>
   #include <rtm/Manager.h>
   #include <rtm/DataFlowComponentBase.h>
   #include <rtm/CorbaPort.h>
   #include <rtm/DataInPort.h>
   #include <rtm/DataOutPort.h>
   #include <cnoid/MultiValueSeq>
   #include <vector>
   
   class RobotTorqueControllerRTC : public RTC::DataFlowComponentBase
   {
   public:
       RobotTorqueControllerRTC(RTC::Manager* manager);
       ~RobotTorqueControllerRTC();
   
       virtual RTC::ReturnCode_t onInitialize();
       virtual RTC::ReturnCode_t onActivated(RTC::UniqueId ec_id);
       virtual RTC::ReturnCode_t onDeactivated(RTC::UniqueId ec_id);
       virtual RTC::ReturnCode_t onExecute(RTC::UniqueId ec_id);
   
   protected:
       // DataInPort declaration
       RTC::TimedDoubleSeq m_angle;
       RTC::InPort<RTC::TimedDoubleSeq> m_angleIn;
   
       // DataOutPort declaration
       RTC::TimedDoubleSeq m_torque;
       RTC::OutPort<RTC::TimedDoubleSeq> m_torqueOut;
   
   private:
       cnoid::MultiValueSeqPtr qseq;
       std::vector<double> q0;
       cnoid::MultiValueSeq::Frame oldFrame;
       int currentFrame;
       double timeStep_;
   };
   
   extern "C"
   {
       DLL_EXPORT void RobotTorqueControllerRTCInit(RTC::Manager* manager);
   };
   
   #endif

今回はトルクの出力をしなければならないので、出力ポートのための設定が増加しています。
`RTC::OutPort<RTC::TimedDoubleSeq>` はRTCの出力ポートを表す型であり、出力ポートを操作するにはこれを利用します。

コントローラのソースコードは以下になります。Choreonoidに含まれるサンプルのSR1WalkControllerRTC.cppを基にしています。 ::

   /**
      Sample Robot motion controller for the JVRC robot model.
      This program was ported from the "SR1WalkControllerRTC.cpp" sample of
      Choreonoid.
   */
   
   #include "RobotTorqueControllerRTC.h"
   #include <cnoid/BodyMotion>
   #include <cnoid/ExecutablePath>
   #include <cnoid/FileUtil>
   
   using namespace std;
   using namespace cnoid;
   
   namespace {
   
   static const double pgain[] = {
       50000.0, 30000.0, 30000.0, 30000.0, 30000.0,
       80000.0, 80000.0, 10000.0, 3000.0, 30000.0,
       30000.0, 80000.0, 3000.0, 30000.0, 10000.0,
       3000.0, 3000.0, 30000.0, 30000.0, 10000.0,
       3000.0, 30000.0, 3000.0, 3000.0, 3000.0,
       3000.0, 3000.0, 3000.0, 3000.0, 3000.0,
       3000.0, 3000.0, 10000.0, 3000.0, 3000.0,
       30000.0, 3000.0, 3000.0, 3000.0, 3000.0,
       3000.0, 3000.0, 3000.0, 3000.0,
       };
   
   static const double dgain[] = {
       100.0, 100.0, 100.0, 100.0, 100.0,
       100.0, 100.0, 100.0, 100.0, 100.0,
       100.0, 100.0, 100.0, 100.0, 100.0,
       100.0, 100.0, 100.0, 100.0, 100.0,
       100.0, 100.0, 100.0, 100.0, 100.0,
       100.0, 100.0, 100.0, 100.0, 100.0,
       100.0, 100.0, 100.0, 100.0, 100.0,
       100.0, 100.0, 100.0, 100.0, 100.0,
       100.0, 100.0, 100.0, 100.0,
       };
   
   const char* samplepd_spec[] =
   {
       "implementation_id", "RobotTorqueControllerRTC",
       "type_name",         "RobotTorqueControllerRTC",
       "description",       "Robot TorqueController component",
       "version",           "0.1",
       "vendor",            "AIST",
       "category",          "Generic",
       "activity_type",     "DataFlowComponent",
       "max_instance",      "10",
       "language",          "C++",
       "lang_type",         "compile",
       ""
   };
   }
   
   
   RobotTorqueControllerRTC::RobotTorqueControllerRTC(RTC::Manager* manager)
       : RTC::DataFlowComponentBase(manager),
         m_angleIn("q", m_angle),
         m_torqueOut("u", m_torque)
   {
   }
   
   RobotTorqueControllerRTC::~RobotTorqueControllerRTC()
   {
   
   }
   
   
   RTC::ReturnCode_t RobotTorqueControllerRTC::onInitialize()
   {
       // Set InPort buffers
       addInPort("q", m_angleIn);
   
       // Set OutPort buffer
       addOutPort("u", m_torqueOut);
   
       return RTC::RTC_OK;
   }
   
   RTC::ReturnCode_t RobotTorqueControllerRTC::onActivated(RTC::UniqueId ec_id)
   {
       if(!qseq){
           string filename = getNativePathString(
               boost::filesystem::path(shareDirectory())
               / "motion" / "RobotPattern.yaml");
   
           BodyMotion motion;
   
           if(!motion.loadStandardYAMLformat(filename)){
               cout << motion.seqMessage() << endl;
               return RTC::RTC_ERROR;
           }
           qseq = motion.jointPosSeq();
           if(qseq->numFrames() == 0){
               cout << "Empty motion data." << endl;
               return RTC::RTC_ERROR;
           }
           q0.resize(qseq->numParts());
           timeStep_ = qseq->getTimeStep();
       }
   
       m_torque.data.length(qseq->numParts());
   
       if(m_angleIn.isNew()){
           m_angleIn.read();
       }
       for(int i=0; i < qseq->numParts(); ++i){
           q0[i] = m_angle.data[i];
       }
       oldFrame = qseq->frame(0);
       currentFrame = 0;
   
       return RTC::RTC_OK;
   }
   
   
   RTC::ReturnCode_t RobotTorqueControllerRTC::onDeactivated(RTC::UniqueId ec_id)
   {
       return RTC::RTC_OK;
   }
   
   RTC::ReturnCode_t RobotTorqueControllerRTC::onExecute(RTC::UniqueId ec_id)
   {
       if(m_angleIn.isNew()){
               m_angleIn.read();
       }
   
       if(currentFrame > qseq->numFrames()){
               m_torqueOut.write();
               return RTC::RTC_OK;
       }
   
       MultiValueSeq::Frame frame = qseq->frame(currentFrame++);
   
       for(int i=0; i < frame.size(); i++){
               double q_ref = frame[i];
               double q = m_angle.data[i];
               double dq_ref = (q_ref - oldFrame[i]) / timeStep_;
               double dq = (q - q0[i]) / timeStep_;
               m_torque.data[i] = (q_ref - q) * pgain[i]/100.0 + (dq_ref - dq) * dgain[i]/100.0;
               q0[i] = q;
   
               cout << "i = " << i << " ";
               cout << "q_ref = " << frame[i] << " ";
               cout << "q = " << q << " ";
               cout << "dq_ref = " << dq_ref << " ";
               cout << "dq = " << dq << " ";
               cout << "torque = " << m_torque.data[i] << endl;
       }
       oldFrame = frame;
   
       m_torqueOut.write();
   
       return RTC::RTC_OK;
   }
   
   
   extern "C"
   {
       DLL_EXPORT void RobotTorqueControllerRTCInit(RTC::Manager* manager)
       {
           coil::Properties profile(samplepd_spec);
           manager->registerFactory(profile,
                                    RTC::Create<RobotTorqueControllerRTC>,
                                    RTC::Delete<RobotTorqueControllerRTC>);
       }
   };

The procedure to add an output port is similar to adding an input port.

onActivated() のときの処理に注目しましょう。この関数はRTCが有効化された際に一度だけ呼ばれます。
ここで、Choreonoidの共有ディレクトリからRobotPattern.yamlを読み出しています。
これはロボットの全関節角度の軌道を記述した動作パターンファイルです。 `motion.loadStandardYAMLformat()` によりモーションデータに変換します。
onActivated()では初期値の設定も行っています。

Computation of joint torques is added to onExecute(). After reading joint angles, joint torques are computed and stored to m_torque.data[i]. In this tutorial, joint torques are computed by simple PD control. Position gains and derivative gains are defined at the top of the source code. If we can't control joints property, we need to adjust those values. Values stored in `m_torque.data`" are output by calling `m_torqueOut.write()`.

これらのソースコードは 「モデルファイルのインストール」でダウンロードしたリポジトリの「samples/tutorials/rtc/RobotTorqueControllerRTC.cpp」と 「samples/tutorials/rtc/RobotTorqueControllerRTC.h」に保存されています。

Setup of the controller
-----------------------

アイテムビューで「BodyRTC」を選択し、プロパティビューの「コントローラのモジュール名」を「RobotTorqueControllerRTC」とします。これは「コントローラのビルド」で作成したモジュールのパスと対応しています。
さらに、プロパティビューの「自動ポート接続」を true にします。

.. image:: images/property_torque.png

Create a pose sequence
----------------------

ロボットの関節の制御を行うRTコンポーネントの実行周期に合わせて、ロボットの動作パターンを生成するための設定を行います。RTコンポーネントは1[ms]周期で実行されるので、Choreonoidの内部フレームレートを1000に設定します。

Open a configuration panel of the time bar.

.. image:: images/timebar.png

Set 1000 to the value of \"internal frame rate\".

.. image:: images/timebar_config.png

This frame rate defines how many times computation is executed. If its value is 1000, computation is done every 1[ms] and if its value is 100, computation is done every 10[ms].

Create a pose sequence item
---------------------------

まずアイテムビューで「JVRC」を選択します。
次に、「メニュー」の「ファイル」「新規」より「ポーズ列」を選択し「SampleMotion」という名前で追加します。

.. image:: images/motion.png

Then choose \"Pose roll\" followed by \"Display\", \"Display View\" menus. You will see a window as follows.

.. image:: images/pose_role.png

Choose \"JVRC\" in the item view and Press \"initial pose\" button on the tool bar to make the robot to be in the initial posture.

.. image:: images/pose_toolbar.png

ポーズロールにおいて、1.0 を選択して「挿入」を押します。
同様に 2.0, 3.0, 4.0 を選択して「挿入」を押します。

The pose roll should be as follows.

.. image:: images/pose_role2.png

Repeat this procedure until length of the motion becomes 15[s].

ポーズロールで作成したのはキーフレームと呼びます。これより、プログラムで使用するモーションを生成させます。
ツールバーから「ボディモーションの生成」ボタンを押します。

.. image:: images/motion_toolbar.png

モーションはツールバーのボタンで手動で生成しなくても、キーフレームの更新時に自動生成することができます。
これを有効にするにはツールバーの「自動更新モード」のボタンをオンにしてください。

.. image:: images/motion_toolbar2.png

You can find a \"motion\" item as a child of \"SampleMotion\" item. Select this item and save its contents by choosing \"Save as\" menu.

.. image:: images/item_motion.png

「モデルファイルのインストール」でダウンロードしたリポジトリの「samples/tutorials/rtc/」ディレクトリに「RobotMotion.yaml」というファイルで保存します。

Build the controller
--------------------

「モデルファイルのインストール」でダウンロードしたリポジトリの「samples/tutorials/rtc/」ディレクトリに移動し、次のコマンドを実行します。 ::

   make

これにより、「samples/tutorials/rtc/」ディレクトリに「RobotTorqueControllerRTC.so」というファイルが作成されるはずです。

その後、次のコマンドを実行します。 ::

   sudo make install DESTDIR=/usr


Run simulation
--------------

シミュレーションツールバーの「シミュレーション開始ボタン」を押します。
シミュレーションを実行すると今度はなかなかロボットが崩れ落ちず、シミュレーション時間で15秒間の間立ったままの状態になったはずです。
これは、JVRCの制御を行うためのモーションデータが15秒分しか用意していないためです。

.. image:: images/simulation_controller.png


A sample project used in this tutorial
--------------------------------------

You can find a sample project file created by this tutorial in samples/tutorials/cnoid/sample3.cnoid.

.. toctree::
   :maxdepth: 2

