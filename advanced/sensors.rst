Connecting sensors
==================


This section explains how to read sensors on JVRC-1 model.

Open a project file
-------------------

Choose "Open..." in "File" menu and select a project file for JVRC-1. Its name is samples/tutorials/cnoid/sample1.cnoid.


Sensors defined in JVRC-1 model
-------------------------------

You can find sensors defined in the JVRC-1 model by opening samples/tutorials/JVRC-1/main.wrl with a text editor.
For example, you can find an accelerometer and a gyrometer as follows.

::

   DEF JVRC Humanoid {
     humanoidBody [
       DEF PELVIS Joint {
         jointType "free"
         translation 0 0 0.854
         children [
           DEF PELVIS_S Segment {
   	  mass 10
   	  centerOfMass -0.01 0 0.034
   	  momentsOfInertia [0.08958333333333333 0 0 0 0.08958333333333333 0 0 0 0.11249999999999999]
   	  children [
               DEF gsensor AccelerationSensor {
                 sensorId 0
               }
               DEF gyrometer Gyro {
                 sensorId 0
               }
   	    Inline { url "pelvis.wrl" }
   	  ]
   	}

We can find force sensors, named rfsensor, lfsensor and so on. ::

   				DEF rfsensor ForceSensor {
   				  sensorId 0
   				}

   				DEF lfsensor ForceSensor {
   				  sensorId 1
   				}

We can find cameras named rcamera and lcamera, and a range sensor named ranger. ::

   			    DEF NECK_P Joint {
   			      jointType "rotate"
   			      jointAxis "Y"
   			      jointId 17
   			      ulimit [1.0471975511965976] #+60
   			      llimit [-0.8726646259971648] #-50
   			      uvlimit [ 5.75958]
   			      lvlimit [-5.75958]
   			      rotorInertia 0.0596
   			      children [
   			        DEF NECK_P_S Segment {
   				  mass 2
   				  centerOfMass 0.01 0 0.11
   				  momentsOfInertia [0.00968 0 0 0 0.00968 0 0 0 0.00968]
   				  children [
   				    Inline { url "head.wrl" }
   				  ]
   				}
   				DEF rcamera VisionSensor {
   				  translation 0.1 -0.03 0.09
   				  rotation      0.4472 -0.4472 -0.7746 1.8235
   				  frontClipDistance 0.05
   				  width 640
   				  height 480
   				  type "COLOR"
   				  sensorId 0
   				  fieldOfView 1.0
   				} 
   				DEF lcamera VisionSensor {
   				  translation 0.1 0.03 0.09
   				  rotation      0.4472 -0.4472 -0.7746 1.8235
   				  frontClipDistance 0.05
   				  width 640
   				  height 480
   				  type "COLOR"
   				  sensorId 1
   				  fieldOfView 1.0
   				} 
   				DEF ranger RangeSensor {
   				  translation 0.1 0.0 0.0
   				  rotation      0.4472 -0.4472 -0.7746 1.8235
   				  sensorId 0
   				  scanAngle 1.5707963267948966
   				  scanStep 0.011344640137963142
   				  scanRate 100
   				  minDistance 0.1
   				  maxDistance 30.0
   				} 
   			      ]
   			    } # NECK_P

You can find data types for each sensor in the following webpage. But the webpage is rather old and some of data types are obsolete.

http://www.openrtp.jp/openhrp3/jp/controller_bridge.html

Data type for an accelerometer is TimedDoubleSeq and its length is 3. It contains accelerations in x,y and z directions.

Data type for a gyrometer is TimedDoubleSeq and its length is 3. It contains angular velocities in x,y and z directions.

Data type for a force/torque sensor is TimedDoubleSeq and its length is 6. 3 components out of 6 are for forces in x,y and z directions and the other 3 are for torques around x,y and z axes.

Data type of the camera image is Img::TimedCameraImage.

https://github.com/s-nakaoka/choreonoid/blob/master/src/OpenRTMPlugin/corba/CameraImage.idl

Img::TimedCameraImage is defined as follows.

.. code-block:: idl

   enum ColorFormat
   {
     CF_UNKNOWN, CF_GRAY, CF_RGB,
     CF_GRAY_JPEG, CF_RGB_JPEG // local extension
   };

   struct ImageData
   {
     long width;
     long height;
     ColorFormat format;
     sequence<octet> raw_data;
   };

   struct CameraImage
   {
     RTC::Time captured_time;
     ImageData image;
     CameraIntrinsicParameter intrinsic;
     Mat44 extrinsic;
   };
   struct TimedCameraImage
   {
     RTC::Time tm;
     CameraImage data;
     long error_code;
   };


data.image.raw_date contains width x height pixels. Definition of a pixel depends on the pixel format specified by format field.
Cameras on JVRC-1 have 640 pixel width and 480 pixel height. Therefore raw_data contains data for 640x480 pixels.

Data type of a range sensor is RTC::RangeData.

.. code-block:: idl

    typedef sequence<double> RangeList;
    struct RangeData
    {
        /// Time stamp.
        Time tm;
        /// Range values in metres.
        RangeList ranges;
        /// Geometry of the ranger at the time the scan data was measured.
        RangerGeometry geometry;
        /// Configuration of the ranger at the time the scan data was measured.
        RangerConfig config;
    };

Measured distances from right to left are stored in ranges. If measurement of distance fails 0 is stored.


Source code of a controller
---------------------------

A header file of the controller is as follows. This file was created by modifying SR1WalkControllerRTC.h which is included in Choreonoid.

.. code-block:: cpp

   /**
      Sample Robot motion controller for the JVRC robot model.
      This program was ported from the "SR1WalkControllerRTC.h" sample of Choreonoid.
   */
   
   #ifndef RobotSensorsControllerRTC_H
   #define RobotSensorsControllerRTC_H
   
   #include <rtm/idl/BasicDataTypeSkel.h>
   #include <rtm/idl/ExtendedDataTypes.hh>
   #include <rtm/idl/InterfaceDataTypes.hh>
   #include <rtm/Manager.h>
   #include <rtm/DataFlowComponentBase.h>
   #include <rtm/CorbaPort.h>
   #include <rtm/DataInPort.h>
   #include <rtm/DataOutPort.h>
   #include <cnoid/MultiValueSeq>
   // #include <cnoid/corba/CameraImage.hh>
   
   class RobotSensorsControllerRTC : public RTC::DataFlowComponentBase
   {
   public:
       RobotSensorsControllerRTC(RTC::Manager* manager);
       ~RobotSensorsControllerRTC();
   
       virtual RTC::ReturnCode_t onInitialize();
       virtual RTC::ReturnCode_t onActivated(RTC::UniqueId ec_id);
       virtual RTC::ReturnCode_t onDeactivated(RTC::UniqueId ec_id);
       virtual RTC::ReturnCode_t onExecute(RTC::UniqueId ec_id);
   
   protected:
       // DataInPort declaration
       RTC::TimedDoubleSeq m_angle;
       RTC::InPort<RTC::TimedDoubleSeq> m_angleIn;
       RTC::TimedDoubleSeq m_gsensor;
       RTC::InPort<RTC::TimedDoubleSeq> m_gsensorIn;
       RTC::TimedDoubleSeq m_gyrometer;
       RTC::InPort<RTC::TimedDoubleSeq> m_gyrometerIn;
       RTC::TimedDoubleSeq m_lfsensor;
       RTC::InPort<RTC::TimedDoubleSeq> m_lfsensorIn;
       RTC::TimedDoubleSeq m_rfsensor;
       RTC::InPort<RTC::TimedDoubleSeq> m_rfsensorIn;
       // Img::TimedCameraImage m_lcamera;
       // RTC::InPort<Img::TimedCameraImage> m_lcameraIn;
       // Img::TimedCameraImage m_rcamera;
       // RTC::InPort<Img::TimedCameraImage> m_rcameraIn;
       RTC::RangeData m_ranger;
       RTC::InPort<RTC::RangeData> m_rangerIn;
   };
   
   extern "C"
   {
       DLL_EXPORT void RobotSensorsControllerRTCInit(RTC::Manager* manager);
   };
   
   #endif

Source codes of the controller are as follows. This file was created by modifying SR1WalkConrollerRTC.cpp which is included in Choreonoid.

.. code-block:: cpp

   /**
      Sample Robot motion controller for the JVRC robot model.
      This program was ported from the "SR1WalkControllerRTC.cpp" sample of
      Choreonoid.
   */
   
   #include "RobotSensorsControllerRTC.h"
   #include <cnoid/BodyMotion>
   #include <cnoid/ExecutablePath>
   #include <cnoid/FileUtil>
   #include <iostream>
   
   using namespace std;
   using namespace cnoid;
   
   namespace {
   
   const char* samplepd_spec[] =
   {
       "implementation_id", "RobotSensorsControllerRTC",
       "type_name",         "RobotSensorsControllerRTC",
       "description",       "Robot Controller component",
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
   
   
   RobotSensorsControllerRTC::RobotSensorsControllerRTC(RTC::Manager* manager)
       : RTC::DataFlowComponentBase(manager),
         m_angleIn("q", m_angle),
         m_gsensorIn("gsensor", m_gsensor),
         m_gyrometerIn("gyrometer", m_gyrometer),
         m_lfsensorIn("lfsensor", m_lfsensor),
         m_rfsensorIn("rfsensor", m_rfsensor),
         m_rangerIn("ranger", m_ranger)
         // m_lcameraIn("lcamera", m_lcamera),
         // m_rcameraIn("rcamera", m_rcamera),
         // m_rangerIn("ranger", m_ranger)
   {
   
   }
   
   RobotSensorsControllerRTC::~RobotSensorsControllerRTC()
   {
   
   }
   
   
   RTC::ReturnCode_t RobotSensorsControllerRTC::onInitialize()
   {
       // Set InPort buffers
       addInPort("q", m_angleIn);
       addInPort("gsensor", m_gsensorIn);
       addInPort("gyrometer", m_gyrometerIn);
       addInPort("lfsensor", m_lfsensorIn);
       addInPort("rfsensor", m_rfsensorIn);
       // addInPort("lcamera", m_lcameraIn);
       // addInPort("rcamera", m_rcameraIn);
       addInPort("ranger", m_rangerIn);
   
       cout << "hoge" << endl;
   
       return RTC::RTC_OK;
   }
   
   RTC::ReturnCode_t RobotSensorsControllerRTC::onActivated(RTC::UniqueId ec_id)
   {
       return RTC::RTC_OK;
   }
   
   
   RTC::ReturnCode_t RobotSensorsControllerRTC::onDeactivated(RTC::UniqueId ec_id)
   {
       return RTC::RTC_OK;
   }
   
   RTC::ReturnCode_t RobotSensorsControllerRTC::onExecute(RTC::UniqueId ec_id)
   {
       if(m_angleIn.isNew()){
               m_angleIn.read();
       }
   
       for(size_t i=0; i < m_angle.data.length(); ++i){
               // cout << "m_angle.data[" << i << "] is " << m_angle.data[i] << std::endl;
       }
   
       if(m_gsensorIn.isNew()){
               m_gsensorIn.read();
       }
   
       for(size_t i=0; i < m_gsensor.data.length(); ++i){
               cout << "m_gsensor.data[" << i << "] is " << m_gsensor.data[i] << std::endl;
       }
   
       if(m_gyrometerIn.isNew()){
               m_gyrometerIn.read();
       }
   
       for(size_t i=0; i < m_gyrometer.data.length(); ++i){
               cout << "m_gyrometer.data[" << i << "] is " << m_gyrometer.data[i] << std::endl;
       }
   
       if(m_lfsensorIn.isNew()){
               m_lfsensorIn.read();
       }
   
       for(size_t i=0; i < m_lfsensor.data.length(); ++i){
               cout << "m_lfsensorIn.data[" << i << "] is " << m_lfsensor.data[i] << std::endl;
       }
   
       if(m_rfsensorIn.isNew()){
               m_rfsensorIn.read();
       }
   
       for(size_t i=0; i < m_rfsensor.data.length(); ++i){
               cout << "m_rfsensorIn.data[" << i << "] is " << m_rfsensor.data[i] << std::endl;
       }
   
       // if(m_lcameraIn.isNew()){
       //     m_lcameraIn.read();
       // }
       //
       // for(size_t i=0; i < m_lcamera.data.image.raw_data.length(); ++i){
       //         cout << "m_lcameraIn.data.image.raw_data[" << i <<
       //                 "] is " << m_lcamera.data.image.raw_data[i] << std::endl;
       // }
       //
       // if(m_rcameraIn.isNew()){
       //     m_rcameraIn.read();
       // }
       //
       // for(size_t i=0; i < m_rcamera.data.image.raw_data.length(); ++i){
       //         cout << "m_rcameraIn.data.image.raw_data[" << i <<
       //                 "] is " << m_rcamera.data.image.raw_data[i] << std::endl;
       // }
   
       if(m_rangerIn.isNew()){
               m_rangerIn.read();
       }
   
       for(size_t i=0; i < m_ranger.ranges.length(); ++i){
               cout << "m_rangerIn.ranges[" << i << "] is " << m_ranger.ranges[i] << std::endl;
       }
       return RTC::RTC_OK;
   }
   
   
   extern "C"
   {
       DLL_EXPORT void RobotSensorsControllerRTCInit(RTC::Manager* manager)
       {
           coil::Properties profile(samplepd_spec);
           manager->registerFactory(profile,
                                    RTC::Create<RobotSensorsControllerRTC>,
                                    RTC::Delete<RobotSensorsControllerRTC>);
       }
   };

Contents are almost same with the source in the previous tutorial. Input data ports for sensors are just added. Notice that data types are different depending on sensor types.

You can find both of RobotSensorsControllerRTC.h and RobotSensorsControllerRTC.cpp in samples/tutorials.

A configuration file for RTC
----------------------------

In the previous tutorials, data ports are connected automatically Choreonoid. But this function only works with simple port configurations.

Since the port configuration of RTC used in this tutorials is complex, we need to create a configuration file. Please create a file that contains the following lines and name it "RobotSensorsJVRC.conf". And put it in samples/tutorials/rtc. The file will be installed with RTCs. ::

   out-port = q:JOINT_VALUE
   out-port = gsensor:ACCELERATION_SENSOR
   out-port = gyrometer:RATE_GYRO_SENSOR
   out-port = lfsensor:FORCE_SENSOR
   out-port = rfsensor:FORCE_SENSOR
   out-port = rcamera:rcamera:CAMERA_IMAGE
   out-port = lcamera:lcamera:CAMERA_IMAGE
   out-port = ranger:RANGE_SENSOR
   connection = q:RobotSensorsControllerRTC0:q
   connection = gsensor:RobotSensorsControllerRTC0:gsensor
   connection = gyrometer:RobotSensorsControllerRTC0:gyrometer
   connection = lfsensor:RobotSensorsControllerRTC0:lfsensor
   connection = rfsensor:RobotSensorsControllerRTC0:rfsensor
   connection = ranger:RobotSensorsControllerRTC0:ranger

out-port means defintion of a output data port. Its right hand value consists of two values separated by comma. The first value is name of port and the second value is data type.

in-port means definition of an input data port. No input port is defined in this example.

connection defines a connection between data ports. For instance, q:RobotSensorsControllerRTC0:q means to connect this RT component and RobotSensorsControllerRTC0.

This configuration file is used to create data ports of BodyRTC. Data ports of usual RT components are statically defined in their source codes.

Since this configuration file format is similar with OpenHRP, you can refer the following webpage. But please note that the format differs slightly.

http://www.openrtp.jp/openhrp3/jp/controller_bridge.html

Build the controller
--------------------

Go to samples/tutorials/rtc directory and execute the following command.

.. code-block:: bash

   $ make

This command generates RobotSensorsControllerRTC.so in samples/tutorials/rtc directory.

And then, execute the following command.

.. code-block:: bash

   $ sudo make install DESTDIR=/usr

Configuration files for RTC must be placed in shared data directory of Choreonoid(/usr/lib/choreonoid-1.5/rtc). "make install" puts configuration file in the directory.

Setup the controller
--------------------

Select BodyRTC in the item view and set value of its property, "Controller module name" to RobotSensorsControllerRTC. This value corresponds to the filename of the RT component. Set values of properties, "Configuration mode" and "Configuration file name" to "Use Configuration File" and "RobotSensorsJVRC.conf" respectively.

.. image:: images/sensor_config.png

Enable cameras and range sensors
--------------------------------

To enable cameras and range sensors in simulation, do the following settings.

Select AISTSimulator in the item view and create a GLVisionSensorSimulator item and name it GLVisionSimulator.

.. image:: images/vision.png

Select GLVisionSimulator item and set its properties as follows.

Target body to JVRC.

Target sensor to ranger.

.. image:: images/vision_property.png

Run simulation
--------------

Press "Start simulation from the beginning" button on the simulation tool bar.
While simulation is running, sensor outputs are displayed in the terminal you launched Choreonoid.
In addition to joint angles(m_angle), you can see outputs from accelerometers(m_gsensor), gyrometers(m_gyrometer) and other sensors.

.. image:: images/output2.png


A sample project used in this tutorial
--------------------------------------

You can find a sample project file created by this tutorial in samples/tutorials/cnoid/sample3.cnoid.

.. toctree::
   :maxdepth: 2


