option task = {
  name: "alert_mobility_battery",
  every: 10s
}

// Bateria
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "mobility" and r._field == "battery_voltage")
  |> last()
  |> map(fn: (r) => ({
      r with
      _level:
        if r._value < 30.0 then "CRIT"
        else if r._value < 50.0 then "WARN"
        else "OK",
      _message: "Rover battery voltage: " + string(v: r._value) + " V"
  }))
  |> yield(name: "battery_alert")

// Motor RPM
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "mobility" and r._field == "motor_rpm")
  |> last()
  |> map(fn: (r) => ({
      r with
      _level:
        if r._value < 2000.0 or r._value > 5000.0 then "WARN"
        else "OK",
      _message: "Motor RPM: " + string(v: r._value)
  }))
  |> yield(name: "rpm_alert")

// Wheel traction
from(bucket: "lunar-mission")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "mobility" and r._field == "wheel_traction")
  |> last()
  |> map(fn: (r) => ({
      r with
      _level:
        if r._value < 0.3 then "CRIT"
        else if r._value < 0.7 then "WARN"
        else "OK",
      _message: "Wheel traction: " + string(v: r._value)
  }))
  |> yield(name: "traction_alert")
