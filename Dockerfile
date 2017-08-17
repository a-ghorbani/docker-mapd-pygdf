FROM nvidia/cuda:8.0-devel-ubuntu14.04
MAINTAINER Asghar Ghorbani [https://de.linkedin.com/in/aghorbani]

# Configure environment
ARG CONDA_VER="4.3.11"
ARG NUMBA_VERSION="0.33"
ARG MAPD_FILE="mapd-os-3.2.1dev-20170816-fd5eaf9-Linux-x86_64"
ARG PYGDF_COMMIT="d5fcdec"
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

# Install basic tools and Java
RUN apt-get update && \
    apt-get install -y wget git vim openjdk-7-jre libopenblas-dev

# Install conda
RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    curl -s https://repo.continuum.io/miniconda/Miniconda3-${CONDA_VER}-Linux-x86_64.sh -o miniconda.sh && \
    /bin/bash miniconda.sh -f -b -p $CONDA_DIR && \
    rm miniconda.sh && \
    $CONDA_DIR/bin/conda install --quiet --yes conda==${CONDA_VER} && \
    $CONDA_DIR/bin/conda install --quiet --yes 'conda-build=2.0*' && \
    $CONDA_DIR/bin/conda config --system --add channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    conda clean -tipsy

# Install Jupyter Notebook
RUN conda install -y jupyter notebook numba cudatoolkit=8 && \
    conda clean -tipsy
  
# Install Numba
RUN conda install -y -c numba cudatoolkit=8 numba=$NUMBA_VERSION && \
    conda clean -tipsy

# Install MapD
RUN wget https://jenkins-os.mapd.com/job/core-os/81/immerse=on,processor=cuda,sanitizer=off/artifact/build/${MAPD_FILE}.tar.gz && \
    tar -xvf ${MAPD_FILE}.tar.gz && \
    ln -s $MAPD_FILE ./mapd && \
    rm ${MAPD_FILE}.tar.gz
#RUN wget https://builds.mapd.com/os/${MAPD_FILE}.tar.gz

# Add user appuser
RUN useradd -ms /bin/bash appuser
USER appuser
WORKDIR /home/appuser

# Prepend path to libcuda and libjvm for mapd
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server/:/usr/local/nvidia/lib64/
RUN echo $LD_LIBRARY_PATH

# Add pygdf (pin to last known working commit)
RUN git clone https://github.com/gpuopenanalytics/pygdf && cd pygdf && git checkout $PYGDF_COMMIT
RUN conda env create -f=pygdf/conda_environments/notebook_py35.yml && \
    conda install -y conda-build=2.1.10 && \
    conda clean -iltpsy

# Add h2oaiglm
RUN /bin/bash -c "source activate pycudf_notebook_py35" && \
    pip install https://s3.amazonaws.com/h2o-beta-release/goai/h2oaiglm-0.0.1-py2.py3-none-any.whl && \
    pip install pandas seaborn psutil && \
    pip install -e "git+https://github.com/fbcotter/py3nvml#egg=py3nvml"

# Add utils script
COPY ./scripts scripts

CMD bash ./scripts/start.sh

