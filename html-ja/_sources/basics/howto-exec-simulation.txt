Creating a simulation project
=============================


This section explains how to create and run a simple simulation.

Launch Choreonoid
-----------------

Let's launch Choreonoid first. Type the following command in gnome-terminal. ::

 choreonoid

You will see a window as follows.

.. image:: images/choreonoid.png

Open a model file
-----------------

Create a world item named \"World\" first by selecting "File", "New" and "World" menus.

Then load a model file of JVRC-1 by choosing \"OpenHRP model file\" followed by \"File\", \"Open\" menus. The filename is samles/tutorials/JVRC-1/main.wrl.

When you check the checkbox named \"JVRC\", JVRC-1 will be displayed in the scene view as follows.

.. image:: images/model.png

Add a model of the floor
------------------------

To prevent the robot from falling, let's add a model of the ground.

The window of Choreonoid has a tab named \"item\". This tab is called \"item view\". Select \"World\" item first in the item view. Then choose \"OpenHRP model file\" following \"File\",\"Open\" menus and select the model file for the floor. Its filename is \"/usr/share/choreonoid-1.5/model/misc/floor.wrl\".

Add a simulator item
--------------------

Choose \"World\" item in the item view. Then create a \"AISTSimulator\" item by following \"File\", \"New\" menus.

.. image:: images/aist_simulator.png

Run simulation
--------------

Next press \"Start simulation\" button in the simulation tool bar. Simulation will start.

.. image:: images/simulation_start.png

Just after starting simulation, the robot falls down.

.. image:: images/simulation_no_controller.png

Because all joints are not controlled but free. We will control joints in the next section to keep the standing position.

Save a project
--------------

After running simulation, let's save the project. Choose \"Save as\" menu in \"File\" menu and name the project file.

A sample project used in this tutorial
--------------------------------------

You can find a sample project file created by this tutorial in samples/tutorials/cnoid/sample1.cnoid.

.. toctree::
   :maxdepth: 2

