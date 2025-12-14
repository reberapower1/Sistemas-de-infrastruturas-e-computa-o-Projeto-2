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
        ber = random.uniform(0.2,0.9)
        latency_ms = random.uniform(500, 800)
        status = "degraded"
    else:
        snr_db = random.uniform(20, 30)
        ber = random.uniform(0.01,0.09)
        latency_ms = random.uniform(150, 350)
        status = "nominal"

    line = (
    f"hga,link_status={status} snr_db={snr_db:.2f},ber={ber:.5f},latency_ms={latency_ms:.2f}"
    )

    return line

if __name__ == "__main__":
    while True:
        for _ in range(10):
            line = generate_hga_point()
            producer.send(TOPIC, line)
            print(line)
        producer.flush()
        time.sleep(5)