Install
=======

This chapter explains how to install a software package, download a mode and sample files used in the tutorials. The verion of OS used in the tutorials is Ubuntu 14.04LTS(64bit).


Installation of Choreonoid
--------------------------

Execute the following commands in gnome-terminal. Chorenoid and required packages are installed. ::

 sudo add-apt-repository ppa:hrg/daily
 sudo apt-get update
 sudo apt-get install choreonoid openrtm-aist


Downloading sample files
------------------------

Download sample files used in the tutorials. Git command is used to download the files. Git command can be installed by the next command ::

 sudo apt-get install git

The sample files can be downloaded by the next command. ::

 git clone https://github.com/jvrc/samples

"samples" directory created by the command above contains a git repository for sample files.

Downloading a model file
------------------------

Let's use a model file of JVRC-1 which is available on the official website of JVRC. Please download the model file from the follwing webpage and extract the file under samples/tutorials.

  https://jvrc.org/download.html


