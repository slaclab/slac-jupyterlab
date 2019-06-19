FROM nvidia/cuda:10.0-cudnn7-devel-centos7

USER root
RUN   yum install -y epel-release \
        && yum repolist \
        && yum -y upgrade

RUN   yum -y install centos-release-scl && \
      yum-config-manager --enable rhel-server-rhscl-7-rpms && \
      yum -y install rh-git29 devtoolset-6 devtoolset-7 devtoolset-8 \
        rh-python36 rh-python36-python-devel rh-python36-python-setuptools-36 rh-python36-python-tkinter rh-python36-PyYAML \
        git bazel \
        python-devel http-parser nodejs perl-Digest-MD5 \
        zlib-devel perl-ExtUtils-MakeMaker gettext \
        gcc make openssl-devel libffi-devel \
        graphviz \
        pandoc \
        texlive texlive-collection-xetex texlive-ec texlive-upquote texlive-adjustbox \
        wget jq \
        bzip2 zip unzip lrzip \
        tree \
        ack screen tmux \
        vim-enhanced emacs emacs-nox nano pico \
        man-pages man-db \
        libarchive-devel \
        fuse-sshfs \
        singularity \
        geos-devel \
        && yum clean all

###
# install mpi
###
RUN  yum -y groupinstall "Development Tools" && \
      yum clean all && \
      mkdir /tmp/git && cd /tmp/git && \
      git clone https://github.com/open-mpi/ompi.git && \
      cd ompi && \
      git checkout v4.0.0 && \
      ./autogen.pl && \
      ./configure --prefix=/usr/local && \
      make -j 16 && \
      make install && \
      /usr/local/bin/mpicc examples/ring_c.c -o /usr/bin/mpi_ring && \
      rm -rf /tmp/git

###
# proj for cartopy
###
RUN mkdir /tmp/proj4 \
      && cd /tmp/proj4 \
      && git clone https://github.com/OSGeo/proj.4.git \
      && cd /tmp/proj4/proj.4 \
      && git checkout 4.9.3 \
      && ./autogen.sh \
      && ./configure \ 
      && make -j 16 \
      && make install \
      && rm -rf /tmp/proj4

# pip etc
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade pip setuptools==39.1.0 wheel

# base libraries
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade \
        virtualenv \
        virtualenvwrapper \
        pipenv \
        tornado==5.1.1 \
        jupyterlab \
        jupyterlab_server \
        jupyterhub \
        jupyter-server-proxy \
        jupyterlabutils \
        jupyter-firefly-extensions \
        ipykernel \
        nbdime \
        nbval \
        ipyevents \
        ipywidgets \
        tqdm \
        paramnb \
        cython \
        gputil \
        psutil \
        gsutil \
        pygments \
        humanize \
        pypandoc \
        jupyterlab-git \
        jupyterlab_latex \
        pyct

# data libraries
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade \
        numpy==1.14.5 \
        scipy \
        pandas \
        uproot \
        papermill \
        tbb \
        icc-rt \
        pyculib \
        numba \
        pypandoc \
        pytraj \
        mrcfile

# machine learning libs
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade \
        kaggle \
        fastai \
        nltk \
        h5py \
        mat4py \
        scikit-image \
        Pillow \
        opencv-python \
        scikit-learn \
        Theano \
        tensorflow-gpu \
        tensorboard \
        jupyter-tensorboard \
        keras \
        torch \
        torchvision \
        pymc3 \
        pystan \
        edward

RUN source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade \
        torch-scatter torch-sparse torch-cluster torch-spline-conv torch-geometric 
        
# visualisation libs
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade \
        rise \
        graphviz \
        matplotlib \
        tables \
        qgrid \
        ipympl \
        bokeh \
        seaborn \
        bqplot \
        ipyvolume \
        pyviz \
        "holoviews[recommended]" \
        datashader \
        wordcloud \
        textblob \
        nglview \
        gmaps

# compute and transport
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade \
        mkl \
        mkl-fft \
        "dask[complete]" \
        dask-kubernetes \
        fastparquet \
        pyarrow \
        cloudpickle \
        firefly_client \
        mpi4py \
        ipyparallel \
        horovod \
        deap \
        zmq
      
RUN  server_extensions="jupyterlab \
        jupyter_server_proxy \
        nbdime \
        jupyterlab_latex \
        jupyterlab_git \
        ipyparallel" && \
      source scl_source enable rh-python36 && \
      set -e && \
      for s in ${server_extensions}; do \
        jupyter serverextension enable ${s} --py --sys-prefix; \
      done
      
RUN  notebook_extensions="widgetsnbextension \
        ipyevents \
        nbdime \
        rise \
        qgrid \
        nglview \
        ipyvolume \
        ipyparallel" && \
      source scl_source enable rh-python36 && \
      set -e && \
      for n in ${notebook_extensions}; do \
        jupyter nbextension install --py --sys-prefix ${n}; \
        jupyter nbextension enable --py --sys-prefix ${n}; \
      done

RUN  lab_extensions="@jupyterlab/celltags \
        @enlznep/runall-extension \
        @jupyterlab/toc \
        jupyterlab-spreadsheet \
        @krassowski/jupyterlab_go_to_definition \
        @jupyter-widgets/jupyterlab-manager \
        jupyterlab-server-proxy \
        @lsst-sqre/jupyterlab-savequit \
        @pyviz/jupyterlab_pyviz \
        bqplot \
        dask-labextension \
        ipyevents \
        ipyvolume \
        nglview-js-widgets \
        jupyter-threejs \
        jupyter-matplotlib \
        jupyterlab_bokeh \
        nbdime-jupyterlab \
        jupyter_firefly_extensions \
        @jupyterlab/latex \
        jupyterlab-drawio \
        @jupyterlab/git \
        @jupyterlab/google-drive \
        @lckr/jupyterlab_variableinspector \
        jupyterlab_tensorboard \
        @jupyterlab/hub-extension" && \
      source scl_source enable rh-python36 && \
      set -e && \
      for l in ${lab_extensions}; do \
        jupyter labextension install --no-build ${l} ; \
        jupyter labextension enable ${l} ; \
      done

ENV  NODE_OPTIONS=--max-old-space-size=4096
RUN  source scl_source enable rh-python36 && \
      npm cache clean && \
      jupyter lab clean && \
      jupyter lab build

RUN curl -L https://github.com/javabean/su-exec/releases/download/v0.2/su-exec.amd64 > /usr/bin/su-exec \
    && chmod ugo+x /usr/bin/su-exec

# Custom local files
COPY profile.d/local03-showmotd.sh \
      profile.d/local04-pythonrc.sh \
      profile.d/local05-path.sh \
      profile.d/local06-scl.sh \
      profile.d/local07-term.sh \
      profile.d/local08-virtualenvwrapper.sh \
      /etc/profile.d/
RUN  cd /etc/profile.d && \
     for i in local*; do \
         ln ${i} $(basename ${i} .sh).csh ; \
     done
RUN  for i in notebooks idleculler ; do \
        mkdir -p /etc/skel/${i} ; \
     done	

COPY motd /etc/motd
COPY jupyter_notebook_config.json /usr/etc/jupyter
COPY 20_jupytervars /etc/sudoers.d/
COPY pythonrc /etc/skel/.pythonrc
COPY scripts/selfculler.py \
      scripts/launch.bash \
      scripts/lablauncher.bash \
      scripts/runlab.sh \
      scripts/prepuller.sh \
      scripts/post-hook.sh \
      /opt/slac/jupyterlab/

RUN  ln -sf /opt/lsf/curr/conf/lsf.conf.co /etc/lsf.conf \
  &&  ln -sf /afs/slac/package/lsf /opt/lsf

ENV  LANG=C.UTF-8

WORKDIR /tmp
CMD [ "/opt/slac/jupyterlab/lablauncher.bash" ]

