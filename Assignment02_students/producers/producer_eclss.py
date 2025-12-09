import os
import time
import random
from kafka import KafkaProducer

BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
TOPIC = os.getenv("KAFKA_TOPIC", "telemetry-eclss")

producer = KafkaProducer(
    bootstrap_servers=BOOTSTRAP_SERVERS,
    value_serializer=lambda v: v.encode("utf-8")
)

def random_radiation():
    # combina faixas: normal, voo comercial, Chernobyl
    mode = random.random()
    if mode < 0.7:
        return random.uniform(0.06, 0.3)
    elif mode < 0.9:
        return random.uniform(2.1, 2.8)
    else:
        return random.uniform(5.0, 9.4)

def generate_eclss_point():
    external_temp = random.uniform(-170.0, 120.0)
    radiation = random_radiation()
    cabin_pressure = random.uniform(90.0, 110.0)  # kPa

    line = (
        f"eclss,location=cabin "
        f"external_temp={external_temp},"
        f"radiation_svh={radiation},"
        f"cabin_pressure_kpa={cabin_pressure}"
    )
    return line

if __name__ == "__main__":
    while True:
        for _ in range(10):
            line = generate_eclss_point()
            producer.send(TOPIC, line)
        producer.flush()
        time.sleep(5)