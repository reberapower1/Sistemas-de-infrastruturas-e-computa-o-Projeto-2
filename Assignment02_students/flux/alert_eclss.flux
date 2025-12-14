option task = {
  name: "alert_eclss",
  every: 10s
}

// Temperatura externa
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "eclss" and r._field == "external_temp")
  |> last()
  |> map(fn: (r) => ({
      r with
      _level: if r._value >= -170.0 and r._value <= 120.0 then "OK" else "WARN",
      _message: if r._value >= -170.0 and r._value <= 120.0
        then "Temperatura externa dentro do range: " + string(v: r._value) + " °C"
        else "ALERTA: Temperatura externa fora do range: " + string(v: r._value) + " °C"
  }))
  |> yield(name: "external_temp_alert")

// Pressão da cabine
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "eclss" and r._field == "cabin_pressure_kpa")
  |> last()
  |> map(fn: (r) => ({
      r with
      _level: if r._value >= 90.0 and r._value <= 110.0 then "OK" else "WARN",
      _message: "Cabin pressure: " + string(v: r._value) + " kPa"
  }))
  |> yield(name: "cabin_pressure_alert")

// Radiação
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "eclss" and r._field == "radiation_svh")
  |> last()
  |> map(fn: (r) => ({
      r with
      _level:
        if r._value <= 0.3 then "OK"
        else if r._value <= 2.8 then "WARN"
        else "CRIT",
      _message: "Radiation level: " + string(v: r._value) + " µSv/h"
  }))
  |> yield(name: "radiation_alert")
