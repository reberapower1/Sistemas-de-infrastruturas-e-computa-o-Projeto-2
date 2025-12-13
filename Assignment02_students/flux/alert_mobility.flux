// Alerta para a bateria do rover
option task = {
  name: "alert_mobility_battery",
  every: 10s
}

from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "mobility")
  |> filter(fn: (r) => r._field == "battery_voltage")
  |> last()
  |> map(fn: (r) => ({
    r with
    _level: if r._value < 30.0 then "CRIT"
             else if r._value < 50.0 then "WARN"
             else "OK"
  }))
  |> monitor.check(
    data: {
      message: "Battery voltage is ${r._value} V (status: ${r._level})",
      statusData: r
    }
  )
