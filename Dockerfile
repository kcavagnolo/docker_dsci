# base image
FROM nvidia/cuda:8.0-cudnn5-devel

# maintainer
MAINTAINER Ken Cavagnolo <ken@kcavagnolo.com>

# set env
ARG RSTUDIO_VERSION=1.0.136
ARG THEANO_VERSION=rel-0.8.2
ARG TENSORFLOW_VERSION=1.0.0
ARG KERAS_VERSION=1.2.2
ARG LASAGNE_VERSION=''
ARG TORCH_VERSION=latest
ARG CAFFE_VERSION=master
ENV CAFFE_ROOT=/root/caffe
ENV PYCAFFE_ROOT=$CAFFE_ROOT/python
ENV PYTHONPATH=$PYCAFFE_ROOT:$PYTHONPATH
ENV PATH=$CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH

# config jupyter
COPY jupyter_notebook_config.py /root/.jupyter/
COPY run_jupyter.sh /root/
COPY dsci_services.sh /usr/local/bin

# update OS
RUN \
  set -ex && \
  echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | tee /etc/apt/apt.conf.d/no-cache && \
  apt-get update -q -y --fix-missing && \
  apt-get install -y --no-install-recommends \
  	  bc build-essential ca-certificates cmake curl e2fslibs-dev emacs g++ \
	  gcc gfortran git graphviz libatlas-base-dev libatlas3-base libffi-dev \
	  libjasper-runtime libfreetype6 libfreetype6-dev libhdf5-dev \
	  liblcms2-dev libopenblas-base make \
	  libopenblas-dev liblapack-dev libpng12-dev libssl-dev libtiff5-dev \
	  libwebp-dev libzmq3-dev libboost-all-dev libgflags-dev \
	  libgoogle-glog-dev libhdf5-serial-dev libleveldb-dev liblmdb-dev \
	  libopencv-dev libprotobuf-dev libsnappy-dev libblkid-dev \
	  libboost-all-dev libaudit-dev libcurl4-gnutls-dev libxml2-dev maven \
	  nano nginx protobuf-compiler pkg-config python-dev python-flask \
	  python-numpy python-scipy python-nose python-h5py python-skimage \
	  python-matplotlib python-pandas python-pip python-sklearn \
	  python-imaging python-software-properties python-sympy python-all-dev \
	  python-opencv python-pil python-protobuf python-flaskext.wtf \
	  python-gevent python-yaml software-properties-common swig unzip vim \
	  wget zlib1g-dev && \
  update-alternatives --set libblas.so.3 /usr/lib/openblas-base/libblas.so.3 && \  
  useradd rstudio && \
  echo "rstudio:rstudio" | chpasswd && \
  mkdir /home/rstudio && \
  chown rstudio:rstudio /home/rstudio && \
  addgroup rstudio staff && \
  apt-get clean && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

# install python and R
COPY install.r /usr/bin/
RUN \
  curl -O https://bootstrap.pypa.io/get-pip.py && \
  python get-pip.py && \
  rm get-pip.py && \
  pip --no-cache-dir install --upgrade ipython && \
  pip --no-cache-dir install --upgrade \
      Cython ipykernel jupyter path.py Pillow \
      pyopenssl ndg-httpsclient pyasn1 \
      pygments requests six sphinx wheel zmq && \
  python -m ipykernel.kernelspec && \
  chmod +x /usr/bin/install.r && \
  echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list && \
  gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
  gpg -a --export E084DAB9 | apt-key add - && \
  apt-get update -q -y && \
  apt-get install -y --no-install-recommends --upgrade \
  	  r-base r-base-dev r-cran-littler \
	  libapparmor1 gdebi-core && \
  install.r abind acepack AER aod aplpack arm arules arulesViz \
    assertthat automap base64enc BH biglm bit bit64 bitops brew broom car \
    caret caTools chron clusterGeneration coda colorspace combinat config \
    crayon curl data.table DataCombine DBI deepnet dendextend DEoptimR \
    deSolve devtools DiagrammeR dichromat digest diptest DMwR DMwR2 \
    doParallel doSNOW dplyr drat DT dummies dygraphs e1071 effects english \
    evaluate expsmooth fastmatch ff ffbase FinancialInstrument flexmix fma \
    FNN foreach forecast formatR Formula fpc fpp fracdiff fuzzyjoin gclus \
    gdata geosphere ggdendro ggmap ggplot2 git2r glmnet gplots gridBase \
    gridExtra gstat gsubfn gtable gtools h2o hexbin highr Hmisc hms \
    htmltab htmltools htmlwidgets httpuv httr hydroGOF hydroTSM igraph \
    influenceR installr intervals irlba iterators janeaustenr jpeg \
    jsonlite Kendall kernlab knitr labeling latticeExtra lawn lawstat \
    lazyeval leaflet leafletR linprog lme4 lmtest lpSolve lpSolveAPI lsr \
    lubridate magrittr manipulate mapproj maps maptools markdown \
    matrixcalc MatrixModels matrixStats mclust MDPtoolbox memoise mi mime \
    minqa mnormt modeltools mosaic mosaicData multcomp munsell mvtnorm \
    mxnet neuralnet nloptr NMF nortest nza nzr openssl openxlsx pander \
    pbkrtest pkgmaker plotly plyr png prabclus praise proto psych purrr \
    pwr qap qmao quadprog quantmod quantreg R6 randomForest rappdirs \
    raster rattle Rbitcoin Rcmdr RcmdrMisc RColorBrewer Rcpp RcppArmadillo \
    RcppEigen RCurl readr readxl registry relimp reshape reshape2 rgdal \
    rgeos rgl Rglpk RgoogleMaps RGtk2 rJava rjson RJSONIO rmarkdown Rmisc \
    rngtools rnn rnoaa ROAuth robustbase ROCR RODBC rootSolve rowr \
    roxygen2 rprojroot RSelenium RSNNS rsparkling RSQLite rstudio \
    rstudioapi rversions sandwich sas7bdat scales scatterplot3d sendmailR \
    seriation shiny sigmoid slam snow sourcetools sp spacetime sparklyr \
    SparseM splitstackshape sqldf statar statmod stringdist stringi \
    stringr tcltk2 testthat TH.data tibble tidyr timeDate translations \
    trimcluster tseries TSP TTR twitteR UScensus2010 V8 vcd VGAM viridis \
    viridisLite visNetwork whisker withr xgboost xlsx xlsxjars XML xml2 \
    xtable xts yaml zoo RMySQL RPostgresSQL RSQLite XLConnect xlsx \
    foreign dplyr tidyr stringr lubridate ggplot2 graphics ggvis rgl \
    htmlwidgets leaflet dygraphs DT diagrammeR network3D threeJS googlevis \
    car mgcv lme4 nlme randomForest multcomp vcd glmnet survival caret \
    xtable sp maptools maps ggmap zoo xts quantmod Rcpp data.table \
    parallel XML jsonlite httr devtools testthat roxygen2 && \
  wget https://download2.rstudio.org/rstudio-server-${RSTUDIO_VERSION}-amd64.deb && \
  gdebi -n rstudio-server-${RSTUDIO_VERSION}-amd64.deb && \
  wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
  VERSION=$(cat version.txt)  && \
  wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
  gdebi -n ss-latest.deb && \
  rm -f version.txt ss-latest.deb rstudio-server-${RSTUDIO_VERSION}-amd64.deb && \
  cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
  echo '\n\
    \n# Configure httr to perform out-of-band authentication if HTTR_LOCALHOST \
    \n# is not set since a redirect to localhost may not work depending upon \
    \n# where this Docker container is running. \
    \nif(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { \
    \n  options(httr_oob_default = TRUE) \
    \n}' >> /etc/R/Rprofile.site && \
  echo "server-app-armor-enabled=0" >> /etc/rstudio/rserver.conf && \
  apt-get clean && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

# install tensorflow, caffe, java, h2o, h2o.deepwater,
# theano, keras, lasagne, mxnet, chainer
RUN \
  pip --no-cache-dir install --upgrade \
  https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-${TENSORFLOW_VERSION}-cp27-none-linux_x86_64.whl && \
  git clone https://github.com/NVIDIA/caffe.git /root/caffe && \
  cd /root/caffe && \
  for req in $(cat python/requirements.txt) pydot; do pip --no-cache-dir install $req; done && \
  mkdir build && \
  cd build && \
  cmake -DUSE_CUDNN=1 -DBLAS=Open .. && \
  make -j"$(nproc)" all && \
  make install && \
  echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update -q -y && \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends oracle-java7-installer && \
  wget http://h2o-release.s3.amazonaws.com/h2o/latest_stable -O latest && \
  wget --no-check-certificate -i latest -O /opt/h2o.zip && \
  unzip -d /opt /opt/h2o.zip && \
  rm /opt/h2o.zip && \
  cd /opt && \
  cd `find . -name 'h2o.jar' | sed 's/.\///;s/\/h2o.jar//g'` && \
  cp h2o.jar /opt && \
  pip --no-cache-dir install `find . -name "*.whl"` && \
  pip --no-cache-dir install git+git://github.com/Theano/Theano.git@${THEANO_VERSION} && \
  echo "[global]\ndevice=gpu \
       		\nfloatX=float32 \
		\noptimizer_including=cudnn \
		\nmode=FAST_RUN \
		\n[lib]\ncnmem=0.95 \
		\n[nvcc]\nfastmath=True \
		\n[blas]\nldflag = -L/usr/lib/openblas-base -lopenblas \
		\n[DebugMode]\ncheck_finite=1" \
  		> /root/.theanorc && \
  pip --no-cache-dir install git+git://github.com/fchollet/keras.git@${KERAS_VERSION} && \
  pip --no-cache-dir install git+git://github.com/Lasagne/Lasagne.git@${LASAGNE_VERSION} && \
  git clone https://github.com/dmlc/mxnet.git /root/mxnet --recursive && \
  cd /root/mxnet/setup-utils && \
  bash install-mxnet-ubuntu-python.sh && \
  bash install-mxnet-ubuntu-r.sh && \
  pip --no-cache-dir install --upgrade chainer && \
  apt-get clean && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/* && \
  chmod +x /usr/local/bin/dsci_services.sh

# open ports
EXPOSE 3838 6006 8787 8888 54321

# set env
WORKDIR "/root"
CMD ["/usr/local/bin/dsci_services.sh"]

### UNUSED ###
### UNUSED ###
### UNUSED ###
# # # install torch
# # RUN \
# #   git clone https://github.com/torch/distro.git /root/torch --recursive && \
# #   bash /root/torch/install-deps && \
# #   yes yes | /root/torch/install.sh
# #
# # # setup lua env
# # ENV LUA_PATH='/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/root/torch/install/share/lua/5.1/?.lua;/root/torch/install/share/lua/5.1/?/init.lua;./?.lua;/root/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua'
# # ENV LUA_CPATH='/root/.luarocks/lib/lua/5.1/?.so;/root/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
# # ENV PATH=/root/torch/install/bin:$PATH
# # ENV LD_LIBRARY_PATH=/root/torch/install/lib:$LD_LIBRARY_PATH
# # ENV DYLD_LIBRARY_PATH=/root/torch/install/lib:$DYLD_LIBRARY_PATH
# # ENV LUA_CPATH='/root/torch/install/lib/?.so;'$LUA_CPATH
# #
# # # install nn, cutorch, cunn, cuDNN and iTorch
# # RUN \
# #   luarocks install nn && \
# #   luarocks install cutorch && \
# #   luarocks install cunn && \
# #   cd /root && \
# #   git clone https://github.com/soumith/cudnn.torch.git /root/cudnn_torch --branch R4 --recursive && 
# #   cd /root/cudnn_torch && luarocks make && \
# #   git clone https://github.com/facebook/iTorch.git /root/itorch --recursive && \
# #   cd /root/itorch && luarocks make
# #
# # install DIGITS and launch server
# # ARG CUDA_REPO_PKG=cuda-repo-ubuntu1404_7.5-18_amd64.deb
# # ARG ML_REPO_PKG=nvidia-machine-learning-repo-ubuntu1404_4.0-2_amd64.deb
# #RUN \
# #  wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/${CUDA_REPO_PKG} -O /tmp/${CUDA_REPO#_PKG} && \
# #  wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1404/x86_64/${ML_REPO_PKG} -O /tmp/$#{ML_REPO_PKG} && \
# #  dpkg -i /tmp/${CUDA_REPO_PKG} && \
# #  dpkg -i /tmp/${ML_REPO_PKG} && \
# #  rm -f /tmp/${CUDA_REPO_PKG} && \
# #  rm -f /tmp/${ML_REPO_PKG} && \
# #  apt-get update -q -y && \
# #  apt-get install digits
# #
# # install cntk
# # pending...
# # https://github.com/Microsoft/CNTK/blob/master/Tools/docker/CNTK-GPU-Image/Dockerfile
### UNUSED ###
### UNUSED ###
### UNUSED ###
