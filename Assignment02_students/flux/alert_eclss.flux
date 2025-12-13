// Alerta para ECLSS: pressão e radiação
option task = {
  name: "alert_eclss",
  every: 10s
}

// Cabin pressure
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "eclss")
  |> filter(fn: (r) => r._field == "cabin_pressure_kpa")
  |> last()
  |> map(fn: (r) => ({
    r with
    _level: if r._value < 90.0 or r._value > 110.0 then "WARN"
             else "OK"
  }))
  |> monitor.check(
    data: {
      message: "Cabin pressure is ${r._value} kPa (status: ${r._level})",
      statusData: r
    }
  )

// Radiation
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "eclss")
  |> filter(fn: (r) => r._field == "radiation_svh")
  |> last()
  |> map(fn: (r) => ({
    r with
    _level: if r._value > 9.0 then "CRIT"
             else if r._value > 5.0 then "WARN"
             else "OK"
  }))
  |> monitor.check(
    data: {
      message: "Radiation is ${r._value} µSv/h (status: ${r._level})",
      statusData: r
    }
  )
