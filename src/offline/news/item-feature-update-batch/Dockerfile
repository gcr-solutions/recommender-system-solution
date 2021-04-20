FROM python:3.6-slim-buster

RUN pip3 install pandas==1.1.5 scikit-learn numpy boto3 s3fs tqdm
ENV PYTHONUNBUFFERED=TRUE


WORKDIR /opt/ml/processing/input/code/

ADD item-feature-update-batch.py ./

ENTRYPOINT ["python", "/opt/ml/processing/input/code/item-feature-update-batch.py"]

