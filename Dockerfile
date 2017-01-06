FROM crystallang/crystal

RUN apt-get update && \
    apt-get install -y liblapack-dev liblapack-doc-man liblapack-doc liblapack-pic liblapack3 liblapack-test liblapack3gf liblapacke liblapacke-dev libblas-dev libblas-doc liblapacke-dev liblapack-doc && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /opt/crystalla
WORKDIR /opt/crystalla

CMD ["/bin/bash"]
