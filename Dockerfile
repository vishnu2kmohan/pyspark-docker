FROM vishnumohan/jupyter-notebook

MAINTAINER Vishnu Mohan <vishnu@mesosphere.com>

USER root

# Add the Mesosphere repo
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF \
    && DISTRO=debian \
    && CODENAME=jessie \
    && echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" \
       > /etc/apt/sources.list.d/mesosphere.list \
    && cat /etc/apt/sources.list.d/mesosphere.list \
    && echo "Acquire::http::Pipeline-Depth "0";" | \
       tee -a /etc/apt/apt.conf.d/90localsettings \
    && apt-get update \
    && echo "Updated repo data" \
    && apt-get install -yq --no-install-recommends \
       openjdk-7-jre-headless \
       mesos \
    && apt-get clean

USER conda
# There are no py35 conda packages for spark and py4j - create a py34 conda env
RUN conda config --add channels anaconda-cluster \
    && conda create -yq -n py34 python=3.4 anaconda \
    && source activate py34 \
    && conda install -yq -c anaconda-cluster \
       py4j \
       scala \
       spark \
    && conda install -yq \
       cloudpickle \
       seaborn \
    && conda clean -yt \
    && conda clean -yp

EXPOSE 8888
WORKDIR ${CONDA_USER_HOME}/work
ENTRYPOINT ["tini", "--"]
CMD ["notebook.sh"]

# Add local files as late as possible to stay cache friendly
COPY notebook.sh /usr/local/bin/
