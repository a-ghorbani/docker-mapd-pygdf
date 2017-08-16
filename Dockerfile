FROM nvidia/cuda:8.0-devel-ubuntu14.04

RUN apt-get update
RUN apt-get install -y wget git vim

# Add user
RUN useradd -ms /bin/bash appuser
USER appuser
WORKDIR /home/appuser

# Download miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-4.3.11-Linux-x86_64.sh
# Install miniconda
RUN bash Miniconda3-4.3.11-Linux-x86_64.sh -b -p /home/appuser/Miniconda3
# Append PATH to miniconda
ENV PATH=$PATH:/home/appuser/Miniconda3/bin

# Install Jupyter Notebook
RUN conda install -y jupyter notebook

# Install cudatoolkit
RUN conda install -y -c numba cudatoolkit=8

# Install Numba
ARG NUMBA_VERSION=0.33
RUN conda install -y -c numba numba=$NUMBA_VERSION


USER root
# Install Java
RUN apt-get install -y openjdk-7-jre libopenblas-dev

USER appuser
# Add MapD
ARG MAPD_FILE="mapd-os-3.2.1dev-20170816-fd5eaf9-Linux-x86_64"
RUN wget https://jenkins-os.mapd.com/job/core-os/81/immerse=on,processor=cuda,sanitizer=off/artifact/build/${MAPD_FILE}.tar.gz
#RUN wget https://builds.mapd.com/os/${MAPD_FILE}.tar.gz
# Extract MapD
RUN tar -xvf ${MAPD_FILE}.tar.gz
RUN ln -s $MAPD_FILE ./mapd

# Prepend path to libcuda and libjvm for mapd
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server/:/usr/local/nvidia/lib64/
RUN echo $LD_LIBRARY_PATH

# Add pygdf (pin to last known working commit)
ARG PYGDF_COMMIT="d5fcdec"
RUN git clone https://github.com/gpuopenanalytics/pygdf && cd pygdf && git checkout $PYGDF_COMMIT
RUN conda env create -f=pygdf/conda_environments/notebook_py35.yml && conda clean -iltpsy
RUN conda install conda-build=2.1.10 -y

# Add h2oaiglm
RUN /bin/bash -c "source activate pycudf_notebook_py35" && \
    pip install https://s3.amazonaws.com/h2o-beta-release/goai/h2oaiglm-0.0.1-py2.py3-none-any.whl && \
    pip install pandas seaborn psutil && \
    pip install -e "git+https://github.com/fbcotter/py3nvml#egg=py3nvml"

# Add utils script
COPY ./scripts ~/scripts

CMD bash ./scripts/start.sh
