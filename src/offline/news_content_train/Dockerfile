# FROM 763104351884.dkr.ecr.us-east-1.amazonaws.com/tensorflow-training:1.15.3-cpu-py37-ubuntu18.04
ARG REGISTRY_URI
FROM ${REGISTRY_URI}/tensorflow-training:1.15.3-cpu-py37-ubuntu18.04


RUN apt-get update
RUN apt-get install -y --no-install-recommends nginx curl \
&& pip3 install --upgrade pip

RUN apt-get install -y --no-install-recommends wget
RUN apt-get install -y --no-install-recommends ca-certificates
RUN apt-get install -y --no-install-recommends python3-setuptools
RUN apt-get install -y --no-install-recommends git
RUN rm -rf /var/lib/apt/lists/*


RUN pip3 install pandas \
 && pip3 install numpy \
 && pip3 install boto3

RUN pip3 install --no-cache-dir flask
RUN pip3 install --no-cache-dir gevent
RUN pip3 install --no-cache-dir gunicorn
# RUN pip3 install --no-cache-dir fastHan
RUN pip3 install --no-cache-dir marisa_trie
RUN pip3 install --no-cache-dir dgl==0.4.3.post2
RUN pip3 install -e git+http://git@github.com/xiaotinghe/fastHan.git'#egg=fastHan'
RUN pip3 install -e git+http://git@github.com/xiaotinghe/dgl-ke.git'#egg=dglke&subdirectory=python'

RUN rm -rf /root/.cache


ENV PATH="/opt/ml/code:${PATH}"

# /opt/ml and all subdirectories are utilized by SageMaker, we use the /code subdirectory to store our user code.

COPY /src /opt/ml/code

WORKDIR /opt/ml/code

ENTRYPOINT ["python", "train"]
