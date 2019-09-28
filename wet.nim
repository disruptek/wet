import os
import times
import asyncdispatch
import httpclient
import strformat
import strutils
import algorithm

import terminaltables

import forecast


when not defined(ssl):
  {.error: "use ssl".}


proc stripDot(s: string): string =
  result = s
  if s.len == 0 or s[^1] != '.':
    return
  return s[s.low..s.high-1]

proc omit0(f: float; add="%"): string =
  if f == 0.0:
    return ""
  result = &"{f:>6.0f}"
  result = result.stripDot
  result &= add

let
  tfw = initTimeFormat("dddd HH")
  tfwo = initTimeFormat("HH")

proc forecastFor(coords: Coords): WeatherReport =
  var
    response: AsyncResponse
    rec: Recallable = Forecast.recall(coords)

  try:
    response = rec.retried()
  except RestError as e:
    echo "rest error:", e
  let text = waitfor response.body

  result = text.toReport()

proc windSpeeds(dp: DataPoint): string =
  var
    ws = &"{dp.windSpeed:>2.0f}"
    wg = &"{dp.windGust:>2.0f}"
  return &"{ws.stripDot} - {wg.stripDot}"

proc wet(coords="") =
  ## console weather applet
  var ll: Coords
  if coords == "":
    ll = cast[string](os.getEnv("LATLONG")).toCoords()
  else:
    ll = cast[string](coords).toCoords()

  let report = ll.forecastFor()
  var hours = newUnicodeTable()
  hours.separateRows = false
  hours.setHeaders(@[
    newCell("Time", leftpad=1),
    newCell("Cloud"),
    newCell("Rain"),
    newCell("Temp"),
    newCell("Humidity"),
    #newCell("Water"),
    #newCell("Pressure"),
    newCell("Wind"),
    newCell("Summary")])

  let rows = report.hourly.data.reversed()
  var wh: string
  for row in rows:
    if row.time.hour in [0, 23]:
      wh = row.time.format(tfw)
    else:
      wh = row.time.format(tfwo)
    hours.addRow(@[
      &"{wh:>12}",
      omit0(row.cloudCover * 100),
      omit0(row.precipProbability * 100),
      omit0(row.temperature, add=""),
      omit0(row.humidity * 100),
      #omit0(row.precipAccumulation),
      #omit0(row.pressure, add=""),
      row.windSpeeds,
      $row.summary
    ])
  echo hours.render()

  # moon phases? 🌑🌒🌓🌔🌕🌖🌗🌘


when isMainModule:
  import cligen

  dispatch(wet)
