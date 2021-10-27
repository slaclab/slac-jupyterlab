FROM rapidsai/rapidsai:21.10-cuda11.2-runtime-ubuntu20.04-py3.8

# make default shell activate conda rapids environment
# as per https://pythonspeed.com/articles/activate-conda-dockerfile/
RUN echo "conda activate rapids" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

RUN conda env list && conda activate rapids && conda list -n rapids

RUN conda install -c pytorch -c anaconda \
      six==1.15.0 \
      cudatoolkit==11.3.1 cudnn \
      numpy==1.19.5 \
      pytorch==1.8.0 gpytorch==1.4.2 \
      botorch torchvision \
      scikit-learn \
      matplotlib \
      numdifftools 

RUN pip install \
      tensorflow-gpu==2.6.0 \
      tensorflow-datasets tensorflow-hub \
      keras==2.6.0  

ENV PATH=/opt/conda/envs/rapids/bin:${PATH}
ENV PYTHONPATH=/opt/conda/lib/python3.8/site-packages/
