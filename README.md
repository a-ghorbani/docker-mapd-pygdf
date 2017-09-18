Mapd + pygdf 
==========

A docker image for [MapD](https://www.mapd.com/) and [pygdf](http://gpuopenanalytics.com/). 

## Pull the image from Docker Repository

```
docker pull aghorbani/mapd-pygdf
```

## Building the image

```
docker build --rm -t aghorbani/mapd-pygdf .
```

## Running the image

```
nvidia-docker run -it --rm \
    -p 8888:8888 \
    -p 9092:9092 \
    aghorbani/mapd-pygdf [--load-data] [--jupyter-args=<arguments for jupyter>]
```

* `--load-data`: will lead to load the sample [data](https://raw.githubusercontent.com/a-ghorbani/docker-mapd-pygdf/master/scripts/churn.txt) into database.
* `--jupyter-args`: specify arguments you want to pass to `jupyter notebook`.

When all running fine, you can reach 
* *Jupyter notebook* via http://localhost:8888 and 
* *MapD Immerse* via http://localhost:9092 

## Running the image - mount host directory

Many time it is desirable to have data directories to be on the host volume.
With the following command you can mount host directories for database data and jupyter notebook directory.

```
nvidia-docker run -it --rm \
    -p 8888:8888 \
    -p 9092:9092 \
    -v /PATH/TO/LOCAL/NB-DIR/:/home/appuser/notebooks/mein/ \
    -v /PATH/TO/LOCAL/DATA-DIR/:/opt/mapd/data/ \
    aghorbani/mapd-pygdf [--load-data] [--jupyter-args=<arguments for jupyter>]
```


