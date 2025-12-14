import os
import time
import random
import json
from kafka import KafkaProducer

BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
TOPIC = os.getenv("KAFKA_TOPIC", "telemetry-mobility")

producer = KafkaProducer(
    bootstrap_servers=BOOTSTRAP_SERVERS,
    value_serializer=lambda v: v.encode("utf-8")
)

battery_voltage = 100.0  # V

def generate_mobility_point():
    global battery_voltage

    # bateria decai e volta a carregar ciclicamente
    battery_voltage -= random.uniform(0, 0.5)
    if battery_voltage < 20.0:
        battery_voltage = 100.0

    motor_rpm = random.uniform(2000, 5000)

    if random.random() < 0.85:
        wheel_traction = random.uniform(0.7, 1.0)
    else:
        wheel_traction = random.uniform(0.0, 0.3)  # Slippage

    # InfluxDB Line Protocol
    line = (
    f"mobility,unit=rover "
    f"battery_voltage={battery_voltage:.2f},"
    f"motor_rpm={motor_rpm:.2f},"
    f"wheel_traction={wheel_traction:.4f}"
)
 
    return line

if __name__ == "__main__":
    while True:
        for _ in range(10):  # burst de 10 pontos
            line = generate_mobility_point()
            print(line)
            producer.send(TOPIC, line)
        producer.flush()
        time.sleep(5)