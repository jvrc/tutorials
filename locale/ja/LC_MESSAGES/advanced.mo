Þ    #      4      L      L     M  &   j       x   ¦       ¾   2  x   ñ  x   j  .   ã  7         J  ,   k       i   $          ¢  n   ±  ·         Ø     ø  ø     ~   	  :   	  M   À	  R   
  A   a
  e   £
  >   	  L   H  ¸        N  ò   ä  /   ×  ²     S  º       *   '  !   R  I  t     ¾     Ñ     p     þ  6     <   Æ  '     N   +  Ý   z  ì   X     E  '   a  ¿     »   I             N  <  |     m     {   v  ^   ò  a   Q  Ü   ³  Q     Z   â  o  =  Ñ   ­      @      n   Ä    A configuration file for RTC A sample project used in this tutorial Advanced simulations Choose "Open..." in "File" menu and select a project file for JVRC-1. Its name is samples/tutorials/cnoid/sample3.cnoid. Connecting sensors Data type for a force/torque sensor is TimedDoubleSeq and its length is 6. 3 components out of 6 are for forces in x,y and z directions and the other 3 are for torques around x,y and z axes. Data type for a gyrometer is TimedDoubleSeq and its length is 3. It contains angular velocities in x,y and z directions. Data type for an accelerometer is TimedDoubleSeq and its length is 3. It contains accelerations in x,y and z directions. Data type of a range sensor is RTC::RangeData. Data type of the camera image is Img::TimedCameraImage. Enable cameras and range sensors Img::TimedCameraImage is defined as follows. In the previous tutorials, data ports are connected automatically Choreonoid. But this function only works with simple port configurations. Measured distances from right to left are stored in ranges. If measurement of distance fails 0 is stored. Open a project file Run simulation Select AISTSimulator in the item view and create a GLVisionSensorSimulator item and name it GLVisionSimulator. Select BodyRTC in the item view and set value of its property, "Configuration mode" and "Configuration file name" to "Use Configuration File" and "RobotSensorsJVRC.conf" respectively. Sensors defined in JVRC-1 model Setup the controller Since the port configuration of RTC used in this tutorials is complex, we need to create a configuration file. Please create a file that contains the following lines and name it "RobotSensorsJVRC.conf". And put it in /usr/lib/choreonoid-1.5/rtc. :: This chapter explains how to run advanced simulations such as utilization of range sensors using a JVRC-1 model as an example. This section explains how to read sensors on JVRC-1 model. To enable cameras and range sensors in simulation, do the following settings. We can find cameras named rcamera and lcamera, and a range sensor named ranger. :: We can find force sensors, named rfsensor, lfsensor and so on. :: You can find a sample project file created by this tutorial in samples/tutorials/cnoid/sample3.cnoid. You can find data types for each sensor in the following page. You can find details of the configuration file format in the following page. You can find sensors defined in the JVRC-1 model by opening samples/tutorials/JVRC-1/main.wrl with a text editor. For example, you can find an accelerometer and a gyrometer as follows. connection defines a connection between data ports. For instance, q:RobotControllerRTC0:q means to connect this RT component and RobotControllerRTC0. data.image.raw_date contains width x height pixels. Definition of a pixel depends on the pixel format specified by format field. Cameras on JVRC-1 have 640 pixel width and 480 pixel height. Therefore raw_data contains data for 640x480 pixels. in-port means definition of an input data port. out-port means defintion of a output data port. Its right hand value consists of two values separated by comma. The first value is name of port and the second value is data type. Project-Id-Version: jvrc software 0.0.1
Report-Msgid-Bugs-To: 
POT-Creation-Date: 2015-03-31 17:58+0900
PO-Revision-Date: 2015-12-13 22:37+0900
Last-Translator: FULL NAME <EMAIL@ADDRESS>
Language-Team: LANGUAGE <LL@li.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 1.5.4
 RTCã®è¨­å®ãã¡ã¤ã« ãµã³ãã«ãã­ã¸ã§ã¯ãã«ã¤ãã¦ ã·ãã¥ã¬ã¼ã·ã§ã³ã®å¿ç¨ [ã¡ãã¥ã¼]-[ãã­ã¸ã§ã¯ãã®èª­ã¿è¾¼ã¿]ãã JVRC ã¢ãã«ãã¡ã¤ã«ç¨ã®ãã­ã¸ã§ã¯ ããã¡ã¤ã«ãèª­ã¿è¾¼ã¿ã¾ãããã­ã¸ã§ã¯ããã¡ã¤ã«åã¯ããµã³ãã«ãã¡ã¤ã«ã®ã¤ã³ã¹ ãã¼ã«ãã§ãã¦ã³ã­ã¼ããããªãã¸ããªã®ãsamples/tutorials/cnoid/sample3.cnoidãã§ãã ã»ã³ãµã®æ¥ç¶ åã»ã³ãµã®å¤ã¯è¦ç´ æ°6ã®TimedDoubleSeqåã«ãªãã¾ãã3æ¬¡åãã¯ãã«ã®åã¨3æ¬¡åãã¯ãã«ã®ãã«ã¯ãæ ¼ç´ããã¦ãã¾ãã ã¸ã£ã¤ã­ã»ã³ãµã®å¤ã¯è¦ç´ æ°3ã®TimedDoubleSeqåã«ãªãã¾ããä¸æ¬¡åãã¯ãã«ã®è§éåº¦ãæ ¼ç´ããã¦ãã¾ãã å éåº¦ã»ã³ãµã®å¤ã¯è¦ç´ æ°3ã®TimedDoubleSeqåã«ãªãã¾ããããããã®æ¹åã®ä¸¦é²å éåº¦ãæ ¼ç´ããã¦ãã¾ãã è·é¢ã»ã³ãµã®å¤ã¯RangeDataåã«ãªãã¾ãã ã«ã¡ã©ã®å¤ã¯Img::TimedCameraImageåã«ãªãã¾ãã ã«ã¡ã©ãè·é¢ã»ã³ãµã®æå¹å Img::TimedCameraImageã®åã®å®ç¾©ã¯ä»¥ä¸ã®ããã«ãªã£ã¦ãã¾ãã ããã¾ã§ã¯Choreonoidã®èªåè¨­å®ã®æ©è½ãç¨ãã¦RTCã®ãã¼ããçæãã¦ãã¾ããã ããããããã¯ãµã³ãã«å®è¡ç¨ã®ãã®ã§ãåç´ãªRTCã®ãã¼ãå®ç¾©ã«ããä½¿ãã¾ããã ã·ã¼ã±ã³ã¹ã«è¨æ¸¬æ¹åã«åãã£ã¦å³ããã¹ã­ã£ã³ããè·é¢ãã¼ã¿ãæ ¼ç´ããã¦ãã¾ãã è·é¢ã®å¤ã¯ä½ãã«å¹²æ¸ãçºçããéãåºåããã¾ãããå¹²æ¸ããªãå ´åã¯0ã«ãªãã¾ãã ãã­ã¸ã§ã¯ããéã ã·ãã¥ã¬ã¼ã·ã§ã³ãå®è¡ãã ã¢ã¤ãã ãã¥ã¼ã§ãAISTSimulatorããé¸æãããæ°è¦ããããGLè¦è¦ã»ã³ãµã·ãã¥ã¬ã¼ã¿ããé¸æãããGLVisionSimulatorãã¨ããååã§è¿½å ãã¾ãã ã¢ã¤ãã ãã¥ã¼ã§BodyRTCãé¸æãããè¨­å®ã¢ã¼ããããè¨­å®ãã¡ã¤ã«ãä½¿ç¨ãã«ããè¨­å®ãã¡ã¤ã«åãããRobotSensorsJVRC.confãã«è¨­å®ãã¾ãã JVRC ã¢ãã«ã®ã»ã³ãµ ã³ã³ãã­ã¼ã©ã®è¨­å® ä»åã®ã­ãããç¨ã®RTCã¯è¤éãªã®ã§ãè¨­å®ãã¡ã¤ã«ãç¨ãã¦åç¨®ãã¼ããå®ç¾©ããå¿è¦ãããã¾ããæ¬¡ã®ãããªè¨­å®ãã¡ã¤ã«ãç¨æãããã¡ã¤ã«åããRobotSensorsJVRC.confãã¨ãã¾ãããããã/usr/lib/choreonoid-1.5/rtc/ããã£ã¬ã¯ããªã«ç½®ãã¦ããã¾ãã :: ãã®ç« ã§ã¯JVRCã¢ãã«ãã¡ã¤ã«ãç¨ããå¿ç¨çãªã·ãã¥ã¬ã¼ã·ã§ã³ã®ä¾ã«ã¤ãã¦è§£èª¬ãã¾ãã ããã§ã¯JVRCã¢ãã«ã«æ­è¼ãããåç¨®ã»ã³ãµã®ãã¼ã¿ãåå¾ã§ããããã«ãã¾ãã ã·ãã¥ã¬ã¼ã·ã§ã³ã«ããã¦ã«ã¡ã©ãè·é¢ã»ã³ãµãæå¹ã«ãããããä»¥ä¸ã®ä½æ¥­ãè¡ãã¾ãã ã«ã¡ã© rcamera, lcameraãè·é¢ã»ã³ãµ ranger ãç¢ºèªãããã¨ãã§ãã¾ãã :: ä»ã«ããåã»ã³ãµ rfsensor, lfsensorãæ­è¼ããã¦ãããã¨ãåããã¾ãã :: ãã®ãµã³ãã«ã®ãã­ã¸ã§ã¯ããã¡ã¤ã«ã¯ãã¢ãã«ãã¡ã¤ã«ã®ã¤ã³ã¹ãã¼ã«ãã§ãã¦ã³ã­ã¼ããããªãã¸ããªã®ãsamples/tutorials/cnoid/sample3.cnoidãã«ä¿å­ããã¦ãã¾ãã åã»ã³ãµã®ãã¼ã¿ã¿ã¤ãã¯æ¬¡ã®ãã¼ã¸ã«è¨è¼ããã¦ãã¾ãã ãã®è¨­å®ãã¡ã¤ã«è¨è¿°æ³ã®è©³ç´°ã¯æ¬¡ã®ãã¼ã¸ã«è¨è¼ããã¦ãã¾ãã JVRC-1 ã¢ãã«ã«æ­è¼ããã¦ããã»ã³ãµã¯ããã­ã¹ãã¨ãã£ã¿ã§ãsamples/tutorials/JVRC-1/main.wrlããã¡ã¤ã«ãéãã¨ç¢ºèªãããã¨ãã§ãã¾ãã ã¢ãã«ãã¡ã¤ã«ãéãã¨æ¬¡ã®ããã«è¨è¿°ããã¦ãããå éåº¦ã»ã³ãµ gsensor ã¨ã¸ã£ã¤ã­ã»ã³ãµ gyrometer ãæ­è¼ããã¦ãããã¨ããããã¾ãã connectionã¨ã¯RTCã®ãã¼ãæ¥ç¶ã®è¨­å®ã¨ãªãã¾ããä¾ãã°ããq:RobotControllerRTC0:qãã¨ã¯ãã®RTCã®ãã¼ãqã¨RobotControllerRTC0ã³ã³ãã­ã¼ã©ã¨ã®æ¥ç¶è¨­å®ã«ãªãã¾ãã width x heightã®åãã¯ã»ã«ã®è²æå ±ã1ãã¯ã»ã«å½ããformatã¨ãã¦data.image.raw_dateé¨åã«æ ¼ç´ããã¾ãã ä»åã®ã«ã¡ã©ã®å ´åãwidth = 640, height = 480ã¨å®ç¾©ããã¦ããã®ã§ã640x480ã®ãã¼ã¿ã¨ãªãã¾ãã in-portã¯å¥åãã¼ã¿ãã¼ãã®å®ç¾©ãæå³ãã¾ãã out-portã¨ã¯ãRTCã®åºåãã¼ãã®å®ç¾©ã§ããããã¼ãåï¼åãã®å½¢å¼ã§å®ç¾©ãã¾ãã 