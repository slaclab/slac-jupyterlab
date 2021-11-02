FROM rapidsai/rapidsai:21.10-cuda11.4-runtime-ubuntu20.04-py3.8

# make default shell activate conda rapids environment
# as per https://pythonspeed.com/articles/activate-conda-dockerfile/
RUN echo "conda activate rapids" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

RUN conda env list && conda activate rapids && conda list -n rapids

RUN conda install -c anaconda \
      cudatoolkit==11.3.1 cudnn \
      six==1.15.0 \
      numpy==1.19.5 \
      scikit-learn \
      matplotlib \
      numdifftools \
      typing-extensions==3.7.4.3 wrapt==1.12.1 \
      tornado==6.1.0 

RUN conda install -c pytorch \
      cudatoolkit==11.3.1 pytorch==1.10.0 gpytorch \
      botorch torchvision \ 
  && conda clean --all

RUN /opt/conda/envs/rapids/bin/pip install --no-cache-dir \
      tensorflow-gpu==2.6.0 \
      tensorflow-datasets tensorflow-hub \
      keras==2.6.0  

ENV PATH=/opt/conda/envs/rapids/bin:${PATH}
ENV PYTHONPATH=/opt/conda/lib/python3.8/site-packages/
ENV LD_LIBRARY_PATH=/opt/conda/lib:${LD_LIBRARY_PATH}

