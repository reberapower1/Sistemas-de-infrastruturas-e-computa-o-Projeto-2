import os
import time
import random
import math
from kafka import KafkaProducer

BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
TOPIC = os.getenv("KAFKA_TOPIC", "telemetry-comms")

producer = KafkaProducer(
    bootstrap_servers=BOOTSTRAP_SERVERS,
    value_serializer=lambda v: v.encode("utf-8")
)

def generate_hga_point():
    # 20% do tempo degradado
    degraded = random.random() < 0.2

    if degraded:
        snr_db = random.uniform(0, 5)
        ber = random.uniform(0, 1)
        latency_ms = random.uniform(800, 2000)
        status = "degraded"
    else:
        snr_db = random.uniform(15, 30)
        ber = random.uniform(0, 0.0001)
        latency_ms = random.uniform(200, 800)
        status = "nominal"

    line = (
        f"hga,link_status={status} "
        f"snr_db={snr_db},"
        f"ber={ber},"
        f"latency_ms={latency_ms}"
    )
    return line

if __name__ == "__main__":
    while True:
        for _ in range(10):
            line = generate_hga_point()
            producer.send(TOPIC, line)
        producer.flush()
        time.sleep(5)