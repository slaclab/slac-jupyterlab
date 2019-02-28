FROM nvidia/cuda:9.0-cudnn7-runtime-centos7

USER root
RUN  yum install -y epel-release
RUN  yum repolist
RUN  yum -y upgrade

# Python 3.6, tkinter, and git: install from SCL
RUN  yum -y install centos-release-scl && \
     yum-config-manager --enable rhel-server-rhscl-7-rpms && \
     yum -y install rh-git29 devtoolset-6 rh-python36-python-tkinter \
       rh-python36 rh-python36-python-devel rh-python36-python-setuptools-36 \
       rh-python36-PyYAML \
     && yum clean all
     
RUN  yum -y install gcc \
      git bazel sudo \
      python-devel http-parser nodejs perl-Digest-MD5 \
      make zlib-devel perl-ExtUtils-MakeMaker gettext \
      gcc openssl-devel libffi-devel \
      pandoc \
      texlive texlive-collection-xetex texlive-ec texlive-upquote \
      texlive-adjustbox \
      wget emacs \
      bzip2 zip unzip lrzip \
      tree \
      ack screen tmux \
      vim-enhanced emacs-nox \
      libarchive-devel \
      fuse-sshfs \
      jq \
      singularity \
      && yum clean all

RUN  cd /tmp && \
      V="2.10.0" && \
      FN="hub-linux-amd64-${V}" && \
      F="${FN}.tgz" && \
      URL="https://github.com/github/hub/releases/download/v${V}/${F}" && \
      cmd="curl -L ${URL} -o ${F}" && \
      $cmd && \
      tar xpfz ${F} && \
      install -m 0755 ${FN}/bin/hub /usr/bin && \
      rm -rf ${F} ${FN}

# pip etc
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade pip setuptools==39.1.0 wheel

# base libraries
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade \
        virtualenv \
        virtualenvwrapper \
        pipenv \
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
        jupyterlab-git \
        jupyterlab_latex

# data libraries
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade \
        numpy==1.14.5 \
        scipy \
        pandas \
        uproot \
        pypandoc \
        papermill \
        rise \
        pypandoc \
        pyarrow \
        cloudpickle \
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
        keras \
        torch \
        torchvision
        
# visualisation libs
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade \
        graphviz \
        matplotlib \
        tables \
        qgrid \
        ipympl \
        bokeh \
        seaborn \
        bqplot \
        ipyvolume \
        "holoviews[recommended]" \
        datashader \
        wordcloud \
        textblob \
        nglview \
        gmaps
         

# compute and transport
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade \
        "dask[complete]" \
        dask-kubernetes \
        fastparquet \
        firefly_client \
        zmq
      
RUN  server_extensions="jupyterlab \
        jupyter_server_proxy \
        nbdime \
        jupyterlab_latex \
        jupyterlab_git" && \
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
        nglview" && \
      source scl_source enable rh-python36 && \
      set -e && \
      for n in ${notebook_extensions}; do \
        jupyter nbextension install ${n} --py --sys-prefix; \
        jupyter nbextension enable ${n} --py  --sys-prefix; \
      done

RUN  lab_extensions="@jupyterlab/celltags \
        @jupyterlab/toc \
        @krassowski/jupyterlab_go_to_definition \
        @jupyter-widgets/jupyterlab-manager \
        jupyterlab-server-proxy \
        @lsst-sqre/jupyterlab-savequit \
        @pyviz/jupyterlab_pyviz \
        bqplot \
        dask-labextension \
        ipyevents \
        ipyvolume \
        jupyter-threejs \
        jupyterlab_bokeh \
        nbdime-jupyterlab \
        jupyter_firefly_extensions \
        @jupyterlab/latex \
        jupyterlab-drawio \
        @jupyterlab/git \
        @jupyterlab/google-drive \
        @lckr/jupyterlab_variableinspector \
        @jupyterlab/hub-extension" && \
      source scl_source enable rh-python36 && \
      set -e && \
      for l in ${lab_extensions}; do \
        jupyter labextension install ${l} --no-build; \
        jupyter labextension enable ${l} ; \
      done

ENV  NODE_OPTIONS=--max-old-space-size=4096
RUN  source scl_source enable rh-python36 && \
      npm cache clean && \
      jupyter lab clean && \
      jupyter lab build

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

ENV  LANG=C.UTF-8
WORKDIR /tmp
CMD [ "/opt/slac/jupyterlab/lablauncher.bash" ]

