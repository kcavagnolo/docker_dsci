#!/bin/bash
set -e
set -x

/usr/lib/rstudio-server/bin/rserver --server-daemonize 0 &
/usr/bin/shiny-server &
java -jar /opt/h2o.jar &
jupyter notebook --notebook-dir=/opt/notebooks --ip='*' --port=8888 --no-browser
