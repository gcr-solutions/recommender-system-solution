ARG REGISTRY_URI=763104351884.dkr.ecr.us-east-1.amazonaws.com

FROM ${REGISTRY_URI}/tensorflow-training:1.15.3-cpu-py37-ubuntu18.04
# 763104351884.dkr.ecr.us-east-1.amazonaws.com/tensorflow-training:1.15.3-cpu-py37-ubuntu18.04

RUN apt-get update && apt-get install -y --no-install-recommends wget nginx curl ca-certificates \
        python3.7 python3-setuptools python3-dev git && \
        pip3 install --upgrade pip && \
        pip3 config set global.index-url https://opentuna.cn/pypi/web/simple


COPY requirements.txt .
RUN pip3 install --user -r requirements.txt

RUN mkdir -p /opt/ml/model/dkn

WORKDIR /opt/ml/code

COPY /src/* ./

ENTRYPOINT ["python", "batch.py"]
