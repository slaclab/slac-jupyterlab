# SLAC Machine Learning JupyterLab image

## Build


    git clone http://github.com/slaclab/slac-jupyterlab
    cd slac-jupyterlab
    
    docker build . -t slaclab/slac-jupyterlab
    
    docker login
    ...
    docker push slaclab/slac-jupyterlab
    
    
    