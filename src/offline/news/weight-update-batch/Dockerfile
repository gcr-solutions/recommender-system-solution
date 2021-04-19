ARG REGISTRY_URI
FROM ${REGISTRY_URI}/tensorflow-training:1.15.3-cpu-py37-ubuntu18.04

ENV PYTHONUNBUFFERED=TRUE

RUN apt-get update && apt-get install -y && pip3 install --upgrade pip

COPY requirements.txt .
RUN pip3 install --user -r requirements.txt

WORKDIR /opt/ml/processing/input/code/

ADD src/*.py ./

ENTRYPOINT ["python", "/opt/ml/processing/input/code/weight-update-batch.py"]

