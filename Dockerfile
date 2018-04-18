FROM nvidia/cuda:9.0-cudnn7-runtime-centos7
# FROM centos:7

USER root
RUN  yum install -y epel-release
RUN  yum repolist
RUN  yum -y upgrade
RUN  yum -y install gcc \
      git sudo \
      python-devel http-parser nodejs \
      make zlib-devel perl-ExtUtils-MakeMaker gettext \
      pandoc \
      texlive texlive-collection-xetex texlive-ec texlive-upquote \
      texlive-adjustbox \
      && yum clean all
# Python 3.6, tkinter, and git: install from SCL
RUN  yum -y install centos-release-scl && \
     yum-config-manager --enable rhel-server-rhscl-7-rpms && \
     yum -y install rh-git29 devtoolset-6 rh-python36-python-tkinter \
       rh-python36 \
     && yum clean all

RUN  cd /tmp && \
     V="2.2.9" && \
     FN="hub-linux-amd64-${V}" && \
     F="${FN}.tgz" && \
     URL="https://github.com/github/hub/releases/download/v${V}/${F}" && \
     cmd="curl -L ${URL} -o ${F}" && \
     $cmd && \
     tar xpfz ${F} && \
     install -m 0755 ${FN}/bin/hub /usr/bin && \
     rm -rf ${F} ${FN}

RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade pip setuptools
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade virtualenv virtualenvwrapper \
      ipykernel \
      pipenv \
      nbval \
      numpy \
      scipy \
      pandas \
      pypandoc \
      ipywidgets \
      rise \
      matplotlib \
      pypandoc \
      bokeh \
      seaborn \
      pyqtgraph

#nbdime \
      
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install \
        https://github.com/jupyterlab/jupyterlab/zipball/master \
        https://github.com/jupyterlab/jupyterlab_launcher/zipball/master \
        https://github.com/jupyter/notebook/zipball/master \
        https://github.com/jupyterhub/jupyterhub/zipball/master \
        https://github.com/jupyterhub/nbserverproxy/zipball/master
RUN  git ls-remote https://github.com/jupyterlab/jupyterlab.git master | \
       awk '{print $1}' > /root/jupyterlab.commit
#RUN  source scl_source enable rh-python36 && \
#      python3 $(which nbdime) config-git --enable --system
      
#RUN  source scl_source enable rh-python36 && \
#      python3 -m ipykernel install --name 'SLAC_Stack'

RUN source scl_source enable rh-python36 && \
      pip3  --no-cache-dir install \
        https://github.com/ioam/holoviews/zipball/master \
        https://github.com/bokeh/datashader/zipball/master && \
      pip3  --no-cache-dir install \
        https://github.com/ioam/holoviews/zipball/master \
        https://github.com/bokeh/datashader/zipball/master

#ENV  SVXT="jupyterlab nbserverproxy nbdime"
ENV  SVXT="jupyterlab nbserverproxy"
RUN  source scl_source enable rh-python36 && \
       for s in $SVXT; do \
          jupyter serverextension enable ${s} --py --sys-prefix ; \
          python3 $(which jupyter) serverextension enable ${s} --py --sys-prefix ; \
       done

ENV  NBXT="widgetsnbextension rise"
RUN  source scl_source enable rh-python36 && \
       for n in $NBXT; do \
          jupyter nbextension install ${n} --py --sys-prefix ; \
          jupyter nbextension enable ${n} --py  --sys-prefix ; \
          python3 $(which jupyter) nbextension install ${n} --py --sys-prefix ; \
          python3 $(which jupyter) nbextension enable ${n} --py --sys-prefix ; \
       done

ENV  LBXT="@jupyter-widgets/jupyterlab-manager"
RUN  source scl_source enable rh-python36 && \
       for l in $LBXT; do \
          jupyter labextension install ${l} --no-build; \
          python3 $(which jupyter) labextension install ${l} --no-build; \
       done

ENV  GITXT="jupyterlab-hub jupyterlab-savequit jupyterlab_bokeh"
RUN  mkdir -p /usr/share/git && \
      cd /usr/share/git && \
      source scl_source enable rh-python36 && \
        jlpm global add webpack && \
      git clone https://github.com/jupyterhub/jupyterlab-hub.git && \
      git clone https://github.com/lsst-sqre/jupyterlab-savequit && \
      git clone https://github.com/bokeh/jupyterlab_bokeh.git && \
      for i in ${GITXT}; do \
          cd ${i} && \
          source scl_source enable rh-python36 && \
            python3 $(which jupyter) labextension link . --no-build && \
          source scl_source enable rh-python36 && \
            jlpm install --unsafe-perm && \
          source scl_source enable rh-python36 && \
            jlpm run build && \
          cd .. ;\
      done

ENV  jl=/opt/slac/jupyterlab
RUN  mkdir -p ${jl}

RUN  for i in clean build; do \
       source scl_source enable rh-python36 && \
          jupyter lab ${i} ; \
     done

RUN  source scl_source enable rh-python36 && \
      jupyter labextension install jupyterlab_bokeh && \
      python3 $(which jupyter) labextension install jupyterlab_bokeh
RUN  source scl_source enable rh-python36 && \
      jupyter lab build


# frameworks
RUN  source scl_source enable rh-python36 && \
       pip3  --no-cache-dir  install --upgrade pip \
        zmq \
        Scrapy \
        pygments \
        humanize \
        tqdm \
        cython \
        gputil \
        psutil \
        scikit-image \
        Pillow \
        opencv-python \
        scikit-learn \
        tensorflow-gpu \
        tensorboard \
        keras \
        torch torchvision \
        nltk \
        statsmodels 

# Lab extensions require write permissions by running user.
RUN  groupadd -g 768 jupyter && \
     scl="/opt/rh/rh-python36/root/usr/share/" && \
     jl="jupyter/lab" && \
     u="${scl}/${jl}" && \
# If we recursively chown all of the lab directory, it gets rid of permission
# errors on startup....but also radically slows down startup, by about
# three minutes.
     mkdir -p ${u}/staging ${u}/schemas ${u}/themes && \
     for i in /usr/share/git ${u}/staging; do \
         chgrp -R jupyter ${i} ; \
         chmod -R g+w ${i} ; \
     done
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
COPY slac_kernel_py3.json \
       /usr/local/share/jupyter/kernels/slac_stack/kernel.json
COPY motd /etc/motd
COPY jupyter_notebook_config.json /usr/etc/jupyter
COPY 20_jupytervars /etc/sudoers.d/
COPY pythonrc /etc/skel/.pythonrc
COPY slac_kernel_py3.json \
      scripts/selfculler.py \
      scripts/launch.bash \
      scripts/lablauncher.bash \
      scripts/runlab.sh \
      scripts/prepuller.sh \
      ${jl}/
RUN chmod ugo+x ${jl}/*

ENV  LANG=C.UTF-8
WORKDIR /tmp
CMD [ "/opt/slac/jupyterlab/lablauncher.bash" ]
