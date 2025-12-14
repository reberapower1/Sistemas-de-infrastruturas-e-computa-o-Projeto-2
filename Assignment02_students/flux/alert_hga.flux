option task = {
  name: "alert_hga",
  every: 10s
}

// SNR
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "hga" and r._field == "snr_db")
  |> last()
  |> map(fn: (r) => ({
      r with
      _level:
        if r._value < 5.0 then "CRIT"
        else if r._value < 10.0 then "WARN"
        else "OK",
      _message: "HGA SNR: " + string(v: r._value) + " dB"
  }))
  |> yield(name: "snr_alert")

// BER
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "hga" and r._field == "ber")
  |> last()
  |> map(fn: (r) => ({
      r with
      _level:
        if r._value >= 0.02 then "CRIT"
        else if r._value >= 0.01 then "WARN"
        else "OK",
      _message: "HGA BER: " + string(v: r._value)
  }))
  |> yield(name: "ber_alert")

// Latência
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "hga" and r._field == "latency_ms")
  |> last()
  |> map(fn: (r) => ({
      r with
      _level:
        if r._value >= 700.0 then "CRIT"
        else if r._value >= 400.0 then "WARN"
        else "OK",
      _message: "HGA Latency: " + string(v: r._value) + " ms"
  }))
  |> yield(name: "latency_alert")
