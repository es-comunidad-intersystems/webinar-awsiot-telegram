///----- Load a Bunch of Libraries -----

load("api_config.js");  //to Read YAML Configuration settings
load("api_esp32.js");
load('api_sys.js');

load('api_timer.js');
load('api_gpio.js');
load ('api_dht.js');  //Our Temperature Sensor (DHT11 or DHT22)

load ('api_events.js');
load('api_net.js');
load('api_mqtt.js');
load ('api_aws.js');
load ('api_shadow.js');


///----- Some General Variables -----
let isConnected = false;
let isMQTTConnected = false;
let  blink_On=300;  //On period when in blinking mode
let  blink_Off=300;  //Off period when in blinkin mode

///----- Topics for MQTT -----
let deviceId = Cfg.get('device.id');
let TopicSub="devices/commands/"+deviceId;
let TopicPub="devices/sensors/"+deviceId;

///----- read the Pin Configuration from the mos.yml file -----
let pin_DHT=Cfg.get("pin.dht");
let pin_Red=Cfg.get("pin.red");
let pin_Blue=Cfg.get("pin.blue");

///----- Initialize Pins as Input or Output -----
GPIO.set_mode(pin_DHT, GPIO.MODE_INPUT);
GPIO.set_mode(pin_Red,GPIO.MODE_OUTPUT);
GPIO.set_mode(pin_Blue,GPIO.MODE_OUTPUT);

///------ Initialize DHT Library
let dht = DHT.create(pin_DHT, DHT.DHT11);


///------ Initial Led State
GPIO.write(pin_Red,0);
GPIO.write(pin_Blue,0);

/* Initial state setup which could be checked with AWS IoT shadow
   to update the delta. 
*/

let led_state = {
    Red: '0',
    Blue: '1'
};

///let mgos_ota_is_committed = ffi('bool mgos_ota_is_committed()');
let mgos_ota_commit = ffi('bool mgos_ota_commit()');


///------- Function to Update Leds
function updateLeds() {
    if (led_state.Red==="blink") {
       GPIO.blink(pin_Red, blink_On, blink_Off);
    }else {
      GPIO.blink(pin_Red,0,0); //Turn off blinking
      let redlight=(led_state.Red==='1') ? 1:0 ; 
      GPIO.write(pin_Red,redlight);
    }
    if (led_state.Blue==="blink") {
      GPIO.blink(pin_Blue, blink_On, blink_Off);
    }else {
      GPIO.blink(pin_Blue,0,0); //Turn off blinking
      let bluelight=(led_state.Blue==='1') ? 1:0 ; 
      GPIO.write(pin_Blue,bluelight);
   }
}

///------- function to Read Sensors Data (Temperature and Humidity)
let getSensorsData= function() {
    return JSON.stringify({
      led_state: led_state,
      temperature: dht.getTemp(),
      humidity: dht.getHumidity(),
      deviceId: deviceId 
      /*
      ,
      total_ram: Sys.total_ram(),
      free_ram: Sys.free_ram(),
      uptime: Sys.uptime(),
      time: Timer.now()
      */
    });
  };


///------ WIFI Status to Console
///PYD:Was changed from Net.setStatusEventHandler, to Event.addGroupHandler. Some samples are broken.
///Net.setStatusEventHandler(
  Event.addGroupHandler(Net.EVENT_GRP, function(ev, arg)
  {    
    print("WiFi Event:",ev); 
    if(ev === Net.STATUS_DISCONNECTED) {
      print("WiFi DISCONNECTED");
      isConnected = false;
    }
    if(ev === Net.STATUS_CONNECTING) {
      print("WiFi CONNECTING");
      isConnected = false;
    }
    if(ev === Net.STATUS_CONNECTED) {
     print("WiFi CONNECTED");
     isConnected = true;
    }
    if(ev === Net.STATUS_GOT_IP) {
      print("Device got IP");
      isConnected = true;
    }
    }, null);


///------ MQTT Status to Console ------
MQTT.setEventHandler(function(conn,ev,evdata){
    // MG_EV_MQTT_CONNACK
    if( ev === MQTT.EV_CONNACK ) {
      isMQTTConnected = true;
      //PYD: mainDispatch();
      print("MQTT Connection Acknowledge:", JSON.stringify(ev));
      ///PYD+++
      ///bool mgos_ota_is_committed();
      ///if (!mgos_ota_is_committed()) {
          //print("******* COMMIT *****");
          //mgos_ota_commit();
      ///}
      //PYD---
    }
    // MG_EV_MQTT_DISCONNECT
    if( ev === 214 ) {
      isMQTTConnected = false;
      print("MQTT DisConnection:", JSON.stringify(ev));
    }
},null);


// Subscribe to the topic to Update the Leds
MQTT.sub(TopicSub, function(conn, topic, msg) {
  print('Topic: ', topic, 'message:', msg);
  let obj = JSON.parse(msg);
  if ( obj.Red !== undefined) {
    led_state.Red=obj.Red;
  }
  if (obj.Blue !== undefined) {
    led_state.Blue=obj.Blue;
  }
   updateLeds();
}, null);


/* Send ESP device Info to MQTT topic every 20 seconds [20* 1000] */
Timer.set(20*1000 , true /* repeat */, function() {
    updateLeds();
    ///
    let message = getSensorsData();
    if(isConnected) {
      if(isMQTTConnected){
        let ok = MQTT.pub(TopicPub, message, 1, false);
        print('Published:', ok ? 'yes' : 'no', 'topic:', TopicPub, 'message:', message);
      }
    } else {
      print('Device not connected - message:', message);
    }
  }, null);

