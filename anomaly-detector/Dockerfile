FROM bde2020/spark-python-template:2.4.4-hadoop2.7

LABEL maintainer="Fredi Weideli <fredi.weideli@bluewin.ch>"

# COPY README.md .

COPY ml_utils/*.py /ml_utils/

ENV SPARK_APPLICATION_PYTHON_LOCATION "/app/kafka_consumer_producer.py"
ENV SPARK_SUBMIT_ARGS "--packages org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.4"
ENV SPARK_APPLICATION_ARGS ""
