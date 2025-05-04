import gpio
import pixel-strip show PixelStrip
import mqtt
import device
import net

// The MQTT broker address
HOST ::= "192.168.110.253"

// s16e target address
S16E_HOST ::= "192.168.110.4"
S16E_PORT ::= 23

CLIENT-ID ::= device.name
LEDS := gpio.Pin 5
BUTTON_1 := gpio.Pin 6 --input --pull-up

MQTT_STALE_THRESHOLD := Duration --m=2

strip := PixelStrip.uart 2 --pin=LEDS
mqtt_client := mqtt.Client --host=HOST

interface Check:
  setup -> none
  // Maybe returns a short string describing the error.
  // If the check is successful, it returns null.
  check -> string?
TOPIC ::= "toit-mqtt/tutorial"
class CheckDoor:
  name /string := "door"
  topic := "w17/workshop/balconydoor/open"
  open /bool? := null
  state-age /Time? := Time.now

  setup -> none:
    mqtt_client.subscribe topic:: | _/string payload/ByteArray |
      catch --trace:
        state-age = Time.now
        if payload == #[ '1' ]:
          open = true
        else if payload == #[ '0' ]:
          open = false
        else:
          open = null
  constructor name/string topic/string:
    this.name = name
    this.topic = topic
  
  check -> string?:
    if (state-age + MQTT_STALE_THRESHOLD) < Time.now:
      return "$name offline"
    if open == true:
      return "$name open"
    if open == null:
      return "$name offline"
    return null

// class CheckDevice:
//   name /string := "door"
//   topic := "w17/workshop/balconydoor/open"
//   on-string := "ON"
//   off-string := "OFF"
//   active /bool? := null
//   state-age /Time? := Time.now

//   setup -> none:
//     mqtt_client.subscribe topic:: | _/string payload/ByteArray |
//       catch --trace:
//         state-age = Time.now
//         if payload == #[ '1' ]:
//           open = true
//         else if payload == #[ '0' ]:
//           open = false
//         else:
//           open = null
//   constructor name/string topic/string:
//     this.name = name
//     this.topic = topic
  
//   check -> string?:
//     if (state-age + MQTT_STALE_THRESHOLD) < Time.now:
//       return "$name offline"
//     if open == true:
//       return "$name open"
//     if open == null:
//       return "$name offline"
//     return null



checks := [
  CheckDoor "workshop door" "w17/workshop/balconydoor/open",
  CheckDoor "kitchen door" "w17/kitchen/balconydoor/open"
]

button-counter := 0
button-task:
  while true:
    if BUTTON_1.get == 0:
      button-counter = button-counter + 1
      if button-counter == 3:
        button-pressed
    else:
      button-counter = 0 
    sleep --ms=10

DISPLAY_RESULTS_FOR := Duration --s=20
DISPLAY_RESULT_FOR := Duration --s=5

button-pressed:
  results := checks.map: it.check

  //update-leds results
  display-results-until = Time.now + DISPLAY_RESULTS_FOR
  

display-results-until /Time := Time.now

display-results-task:
  RESULT_TICK_DURATION := Duration --ms=200
  current_result_index := 0
  current_result_duration := Duration --s=0
  while true:
    sleep RESULT_TICK_DURATION
    if display-results-until < Time.now:
      display-message ""
      continue
    current-result-duration += RESULT_TICK_DURATION
    if current-result-duration >= DISPLAY_RESULT_FOR:
      current_result_index = (current_result_index + 1) % checks.size
      current_result_duration = Duration --s=0
    
    result := get_next_error current_result_index
    if result == null:
      display-message "Ready for shutdown"
      continue

    display-message "$result.message"
    if result.index != current-result-index:
      current-result-duration = Duration --s=0
      current-result-index = result.index

update-leds-task:
  LED_UPDATE_INTERVAL := Duration --ms=250
  while true:
    sleep LED_UPDATE_INTERVAL
    results := checks.map: it.check
    update-leds results

previous-message := ""
MESSAGE_REFRESH_INTERVAL := Duration --s=10
force-message-refresh-at := Time.now
display-message message/string:
  if message == previous-message and (message == "" or Time.now < force-message-refresh-at):
    return
  force-message-refresh-at = Time.now + MESSAGE_REFRESH_INTERVAL
  client := net.open
  socket := client.tcp-connect S16E_HOST S16E_PORT
  writer := socket.out
  writer.write "TXT                                                              \n"
  writer.write "TXT $message\n"
  previous-message = message
  print message

class NextError:
  message /string
  index /int
  constructor message_/string index_/int:
    message = message_
    index = index_
// Get the index of the next failing check. Returns null if all checks are ok.
get_next_error current/int -> NextError?:
  for index := 0; index < checks.size; index++:
    check_index := (current + index) % checks.size
    result := checks[check_index].check
    if result != null:
      return NextError result check_index
  return null
  
led_red := ByteArray 2
led_green := ByteArray 2
led_blue := ByteArray 2
update-leds results/List:
  errors := results.filter: it != null

  if errors.size == 0:
      led_red[0] = 0
      led_green[0] = 50
      led_blue[0] = 0
  else:
      led_red[0] = 50
      led_green[0] = 0
      led_blue[0] = 0
  
  strip.output led_red led_green led_blue

main:
  mqtt_client.start
    --client-id=CLIENT-ID
    --on-error=:: print "MQTT error: $it"
    --reconnection-strategy=mqtt.TenaciousReconnectionStrategy --delay-lambda=:: Duration --s=(it < 30 ? 2 : 15)
  print "MQTT client connected"

  checks.do:
    it.setup

  task:: button-task
  task:: display-results-task
  task:: update-leds-task