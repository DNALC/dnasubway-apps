DNA Subway Purple Line
======================

The purple line consists of three apps:
1. Import
2. Denoise
3. Corematrix

The apps are mounted on a Docker image whose specifications can be found on ```Dockerfile```. The default entrypoint for this image can be found in ```default_entrypoint.sh```. Each app consists of a runner file (_run-pl-appname.sh_), a wrapper (_wrap-pl-appname.sh_), and a test file (_test-pl-appname.sh_). 

###File descriptions

_run-pl-appname.sh_: entrypoint file that is copied into the app image. This file executes the qiime commands and stores the output files.

_wrap-pl-appname.sh_: sets environment variables and executes a Docker container. In Agave, inputs and parameters from the job file are transformed into the environment variables. Docker image must be built in order to execute this file.

_test-pl-appname.sh_: sets environment variables for local executions and calls _wrap-pl-appname.sh_.



 
