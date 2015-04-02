Connecting a RT component
=========================


This section explains how to connect Choreonoid and a RT component by developing an example component which read joint angles.

Open a project file
-------------------

Open a project file by choosing \"Open a project file\" menu of \"File\" menu.The file name is samples/tutorials/cnoid/sample1.cnoid.

Add a controller
----------------

Select \"JVRC\" first in the item view.
Then create a BodyRTC item by choosing \"BodyRTC\" menu followed by \"File\", \"New\" menus.

Source code of a controller
---------------------------

Contents of the header file of the controller is as follows. This file was created by modifying SR1WalkControllerRTC.h which is included in Choreonoid. ::

   /**
      Sample Robot motion controller for the JVRC robot model.
      This program was ported from the "SR1WalkControllerRTC.h" sample of Choreonoid.
   */
   
   #ifndef RobotControllerRTC_H
   #define RobotControllerRTC_H
   
   #include <rtm/idl/BasicDataTypeSkel.h>
   #include <rtm/Manager.h>
   #include <rtm/DataFlowComponentBase.h>
   #include <rtm/CorbaPort.h>
   #include <rtm/DataInPort.h>
   #include <rtm/DataOutPort.h>
   #include <cnoid/MultiValueSeq>
   
   class RobotControllerRTC : public RTC::DataFlowComponentBase
   {
   public:
       RobotControllerRTC(RTC::Manager* manager);
       ~RobotControllerRTC();
   
       virtual RTC::ReturnCode_t onInitialize();
       virtual RTC::ReturnCode_t onActivated(RTC::UniqueId ec_id);
       virtual RTC::ReturnCode_t onDeactivated(RTC::UniqueId ec_id);
       virtual RTC::ReturnCode_t onExecute(RTC::UniqueId ec_id);
   
   protected:
       // DataInPort declaration
       RTC::TimedDoubleSeq m_angle;
       RTC::InPort<RTC::TimedDoubleSeq> m_angleIn;
   };
   
   extern "C"
   {
       DLL_EXPORT void RobotControllerRTCInit(RTC::Manager* manager);
   };
   
   #endif

`RTC::TimedDoubleSeq` is a type which contains time and double precision values. Seq means a sequence of values just like double[]. 

`RTC::InPort<RTC::TimedDoubleSeq>` defines an input data port. m_angle is a buffer to receive joint angles. Joint angles read through m_angleIn are stored in m_angle.

The following shows source code of the controller. It was developed based on SR1WalkControllerRTC.cpp which is included in Choreonoid. ::

   /**
      Sample Robot motion controller for the JVRC robot model.
      This program was ported from the "SR1WalkControllerRTC.cpp" sample of
      Choreonoid.
   */
   
   #include "RobotControllerRTC.h"
   #include <cnoid/BodyMotion>
   #include <cnoid/ExecutablePath>
   #include <cnoid/FileUtil>
   #include <iostream>
   
   using namespace std;
   using namespace cnoid;
   
   namespace {
   
   const char* samplepd_spec[] =
   {
       "implementation_id", "RobotControllerRTC",
       "type_name",         "RobotControllerRTC",
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
       // Set InPort buffers
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
       DLL_EXPORT void RobotControllerRTCInit(RTC::Manager* manager)
       {
           coil::Properties profile(samplepd_spec);
           manager->registerFactory(profile,
                                    RTC::Create<RobotControllerRTC>,
                                    RTC::Delete<RobotControllerRTC>);
       }
   };

m_angleIn and m_angle are associated by constructor of RobotControllerRTC.

onInitialized is called right after a RT component is constructed. It registers the input port.

onExecute() is a function called periodically. Its implementation of this tutorial just reads joint angles and outputs those values to standard output. m_angleIn.isNew() checks if new data arrived or not. If the arrival is detected, m_angleIn.read() reads data and stores values to m_angle. Joint angles are accesible through m_angle.data.

These source codes are stored as samples/tutorials/rtc/RobotControllerRTC.cpp and samples/tutorials/rtc/RobotControllerRTC.h.

Setup the controller
--------------------

To connect Choreonoid and the RT component we developed, we need to configure BodyRTC item.

When you select BodyRTC item, its properties are displayed in the tab which is called \"property view\". Set \"RobotControllerRTC\" to the value of \"Controller module name\". This corresponds to the filename of the RT component. Set true to the value of \"Automatic port connection\".

.. image:: images/property_rtc.png

Build the controller
--------------------

Go to samples/tutorials/rtc directory and execute the following command. ::

   make

This command generates RobotControllerRTC.so under samples/tutorials/rtc directory.

Then execute the following command. ::

   sudo make install DESTDIR=/usr

In order to use RT components from Choreonoid, we need to put them in the shared directory of Choreonoid(/usr/lib/choreonoid-1.5/rtc). \"make install\" command does this automatically.

Run simulation
--------------

Press \"start simulation\" button on the simulation tool bar. While the simulation is running, joint angles stored in m_angle are displayed in the terminal you launched Choreonoid.

.. image:: images/output.png

Applying joint torques computed using joint angles, we can control joint positions. The next tutorial explains how to do that.

A sample project used in this tutorial
--------------------------------------

You can find a sample project file created by this tutorial in samples/tutorials/cnoid/sample2.cnoid.

.. toctree::
   :maxdepth: 2

