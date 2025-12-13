// Alerta para HGA: SNR, BER e Latência
option task = {
  name: "alert_hga",
  every: 10s
}

// SNR
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "hga")
  |> filter(fn: (r) => r._field == "snr_db")
  |> last()
  |> map(fn: (r) => ({
    r with
    _level: if r._value < 5.0 then "CRIT"
             else if r._value < 15.0 then "WARN"
             else "OK"
  }))
  |> monitor.check(
    data: {
      message: "HGA SNR is ${r._value} dB (status: ${r._level})",
      statusData: r
    }
  )

// BER
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "hga")
  |> filter(fn: (r) => r._field == "ber")
  |> last()
  |> map(fn: (r) => ({
    r with
    _level: if r._value > 0.01 then "CRIT"
             else if r._value > 0.001 then "WARN"
             else "OK"
  }))
  |> monitor.check(
    data: {
      message: "HGA BER is ${r._value} (status: ${r._level})",
      statusData: r
    }
  )

// Latência
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "hga")
  |> filter(fn: (r) => r._field == "latency_ms")
  |> last()
  |> map(fn: (r) => ({
    r with
    _level: if r._value > 1500.0 then "CRIT"
             else if r._value > 1000.0 then "WARN"
             else "OK"
  }))
  |> monitor.check(
    data: {
      message: "HGA latency is ${r._value} ms (status: ${r._level})",
      statusData: r
    }
  )
