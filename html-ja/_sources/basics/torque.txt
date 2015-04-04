Joint control using a RT component
==================================


This section extentds the RT component developed in the previous section to keep the robot standing position.


Open a project file
-------------------

Choose "Open..." in "File" menu and select a project file for JVRC-1. Its name is samples/tutorials/cnoid/sample2.cnoid.

Source code of a controller
---------------------------

A header file of the controller is as follows. This file was created by modifying SR1WalkControllerRTC.h which is included in Choreonoid.

.. code-block:: cpp

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

An output data port is added to output joint torques. `RTC::OutPort<RTC::TimedDoubleSeq>`  is the definition of the output port.

Source codes of the controller are as follows. This file was created by modifying SR1WalkConrollerRTC.cpp which is included in Choreonoid.

.. code-block:: cpp

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

Let's look at implementation of onActivated(). This function is called only once when a RT component is activated. This function reads RobotPattern.yaml in shared data directory of Choreonoid. This file contains joint angle trajectories and it can be loaded by calling `motion.loadStandardYAMLformat()`. onActivated() initializes other variables.

Computation of joint torques is added to onExecute(). After reading joint angles, joint torques are computed and stored to m_torque.data[i]. In this tutorial, joint torques are computed by simple PD control. Position gains and derivative gains are defined at the top of the source code. If we can't control joints property, we need to adjust those values. Values stored in `m_torque.data`" are output by calling `m_torqueOut.write()`.

You can find both of RobotTorqueCOntrollerRTC.h and RobotTorqueControllerRTC.cpp in samples/tutorials.

Setup of the controller
-----------------------

Choose BodyRTC in the item view and change the value of "Controller module name" property to "RobotTorqueControllerRTC". This value corresponds to the filename of the RT component. Change the value of "Auto Connect" to "true".

.. image:: images/property_torque.png

Create a pose sequence
----------------------

Since a joint conrol RT component is executed at 1000[Hz], set the internal framerate of Choreonoid to the same value, 1000In order to set a framerate of a motion pattern to the same value with execution period of a joint control RT component, set the value to 1000.

Open a configuration panel of the time bar.

.. image:: images/timebar.png

Set 1000 to the value of "Internal frame rate".

.. image:: images/timebar_config.png

This frame rate defines how many times computation is executed. If its value is 1000, computation is done every 1[ms] and if its value is 100, computation is done every 10[ms].

Create a pose sequence item
---------------------------

Choose JVRC in the item view first. Then create a pose sequence item named SimpleMotion by choosing "PoseSeq" menu followed by "File", "New..." menus.

.. image:: images/motion.png

Then choose "Pose Roll" followed by "View", "Show View" menus. You will see a window as follows.

.. image:: images/pose_role.png

Choose "JVRC" in the item view and Press "Set the present initial pose to the selected bodies" button on the tool bar to make the robot to be in the initial posture.

.. image:: images/pose_toolbar.png

Select 1.0 in the pose roll and press "Insert". Select 2.0, 3.0 and 4.0 and press "Insert" as well.

The pose roll should be as follows.

.. image:: images/pose_role2.png

Repeat this procedure until length of the motion becomes 15[s].

What we created using the pose roll are called key frames. They are used to generate a robot motion. Press "Generate body motions" button on the tool bar.

.. image:: images/motion_toolbar.png

It is possible to update the robot motion automatically when key frames are updated. It can be enabled by checking  "Automatic Balance Adjustment Mode" button on the tool bar.

.. image:: images/motion_toolbar2.png

You can find a "motion" item as a child of "SampleMotion" item. Select this item and save its contents by choosing "Save Selected Items As" menu.

.. image:: images/item_motion.png

Save the robot motion as RobotMotion.yaml in samples/tutorials/rtc directory.

Build the controller
--------------------

Go to samples/tutorials/rtc directory and execute the following command.

.. code-block:: bash

   $ make

This command generates RobotTorqueControllerRTC.so in samples/tutorials/rtc directory.

And then, execute the following command.

.. code-block:: bash

   $ sudo make install DESTDIR=/usr


Run simulation
--------------

Press "Start simulation from the beginning" button on the simulation tool bar. The robot doesn't fall down for 15[s] but after that, it falls down. Because duration of the robot motion is 15[s].

.. image:: images/simulation_controller.png


A sample project used in this tutorial
--------------------------------------

You can find a sample project file created by this tutorial in samples/tutorials/cnoid/sample3.cnoid.

.. toctree::
   :maxdepth: 2

