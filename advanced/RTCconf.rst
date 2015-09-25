=====================
RTCの設定ファイル
=====================

ここでは、BodyRTCの設定ファイルについて解説します。

設定ファイルには、BodyRTCの入力ポート、出力ポートの設定と、接続先を記述します。


入力ポートの設定
===================

.. code-block:: ini

   in-port = ポート名[:識別名]:プロパティ名

入力ポート名を与え、そのポートのプロパティを指定します。識別名を諸略すると、対象となるデータ全てに入力します。例えば、

.. code-block:: ini

   in-port = tau:JOINT_TORQUE

これは、名前「tau」の入力ポートは、データをJointIdの順に関節トルクに入力することを設定しています。

識別名を指定すれば特定の部位にだけ入力します。識別名はVRMLモデルのノード名を指定します。

識別名はコンマ(,)で区切って複数指定することができます。データは指定した順番で入力します。例えば、

.. code-block:: ini

   in-port = arm_elbow:RARM_ELBOW,LARM_ELBOW:JOINT_VALUE

これは、名前「arm_elbow」の入力ポートは、データをRARM_ELBOWとLARM_ELBOWリンクの関節角度に入力することを設定しています。


出力ポートの設定
====================

.. code-block:: ini

   out-port = ポート名[:識別名]:プロパティ名

出力ポート名を与え、そのポートのプロパティを指定します。識別名を諸略すると、対象となるデータ全てを出力します。例えば、

.. code-block:: ini

   out-port = q:JOINT_VALUE
　　　
これは、名前「ｑ」の出力ポートは、JointIdの順に並べた関節角度を出力することを設定しています。

識別名を指定すれば特定の部位の値だけ出力します。識別名はVRMLモデルのノード名を指定します。

識別名は(,)で区切って複数指定することができます。ただし、識別名が1つしか指定できないプロパティもあります。

指定した順番でデータは出力されます。例えば、

.. code-block:: ini

   out-port = camerac:CAMERA_C:CAMERA_IMAGE

これは、名前「camerac」の出力ポートは、VisionSensor CAMERA_C のセンサデータを出力することを設定しています。


接続の設定
=============

.. code-block:: ini

   connection = ポート名[:コントローラインスタンス名]:コントローラポート名

入出力ポート間の接続を指定します。左はBodyRTCのポート名、右はコントローラのポート名を指定しコロンで区切ります。例えば、

.. code-block:: ini

   connection = q:PDservo0:q

これは、BodyRTCのポートqとPDservo0コントローラのポートqを接続することを設定しています。

コントローラインスタンス名を省略すると、BodyRTCアイテムのプロパティで指定したコントローラを対象にします。


プロパティ一覧
==================

ポート設定で使用するプロパティは以下の通りです。

.. list-table::
   :header-rows: 1
   :widths: 15,13,13,13,35

   * - プロパティ名
     - In Port/Out Port
     - データ型
     - データ長/識別名
     - 説明
   * - JOINT_VALUE
     - yes/yes
     - TimedDoubleSeq
     - 1
     - 関節角度または関節位置
   * - JOINT_VELOCITY
     - yes/yes
     - TimedDoubleSeq
     - 1
     - 同上微分
   * - JOINT_ACCELERATION
     - yes/yes
     - TimedDoubleSeq
     - 1
     - 同上２階微分
   * - JOINT_TORQUE
     - yes/yes
     - TimedDoubleSeq
     - 1
     - 関節トルク
   * - EXTERNAL_FORCE
     - yes(*1)/no
     - TimedDoubleSeq
     - 6
     - 力(3次元ベクトル), トルク(3次元ベクトル)
   * - ABS_TRANSFORM
     - yes(*1)/yes(*1)
     - TimedDoubleSeq
     - 12
     - ワールド座標系における位置姿勢(最初の3要素が位置ベクトル、9要素が姿勢行列)
   * - ABS_VELOCITY
     - yes(*1)/yes(*1)
     - TimedDoubleSeq
     - 6
     - ワールド座標系における速度(3次元ベクトル)と角速度(3次元ベクトル)
   * - FORCE_SENSOR
     - no/yes
     - TimedDoubleSeq
     - 6
     - 力(3次元ベクトル), トルク(3次元ベクトル)
   * - RATE_GYRO_SENSOR
     - no/yes
     - TimedDoubleSeq
     - 3
     - ジャイロセンサ
   * - ACCELERATION_SENSOR
     - no/yes
     - TimedDoubleSeq
     - 3
     - 加速度センサ
   * - RANGE_SENSOR
     - no/yes(*3)
     - RangeData
     - 
     - レンジセンサ
   * - CONSTRAINT_FORCE
     - no/yes(*2)
     - TimedDoubleSeq
     - 6*接触点数
     - ワールド座標系における接触位置(3次元ベクトル)と力(3次元ベクトル)
   * - RATE_GYRO_SENSOR2
     - no/yes(*2)
     - TimedAngularVelocity3D
     - 
     - ジャイロセンサ　TimedAngularVelocity3D型で出力
   * - ACCELERATION_SENSOR2
     - no/yes(*2)
     - TimedAcceleration3D
     - 
     - 加速度センサ　TimedAcceleration3Dで出力
   * - ABS_TRANSFORM2
     - yes(*2)/yes(*2)
     - TimedPose3D
     - 
     - 位置姿勢　TimedPose3Dで入出力
   * - LIGHT
     - yes(*1)/yes(*1)
     - TimedBooleanSeq
     - 1
     - ライトOn/Offの制御と、状態出力
   * - CAMERA_IMAGE
     - no/yes(*3)
     - TimedCameraImage
     - 
     - ビジョンセンサ
   * - CAMERA_RANGE
     - no/yes(*3)
     - PointCloud
     - 
     - ビジョンセンサ


(*1) 識別名を指定した場合に有効。

(*2) 識別名を一つ指定した場合に有効。

(*3) 識別名を一つ指定するか、指定しない場合に有効。（指定しないと、Id=0のセンサを指定したことと同じになる。）






