FROM rapidsai/rapidsai:21.08-cuda11.2-runtime-ubuntu20.04-py3.8

# make default shell activate conda rapids environment
# as per https://pythonspeed.com/articles/activate-conda-dockerfile/
RUN echo "conda activate base" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

RUN conda env list && conda activate rapids && conda list -n rapids

RUN conda install -c pytorch \
      pytorch botorch cudatoolkit=11.2 

#RUN conda install -c anaconda \
#      tensorflow-gpu keras cudatoolkit=11.2 

RUN pip install \
      scikit-learn \
      tensorflow-gpu \
      tensorflow-datasets \
      tensorflow-hub \
      keras 

ENV PYTHONPATH=/opt/conda/lib/python3.8/site-packages/
