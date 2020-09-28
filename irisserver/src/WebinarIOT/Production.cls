Class WebinarIOT.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="WebinarIOT.Production" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description>Production for the IRIS IOT Webinar using MQTT with AWS IOT</Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="Telegram.BO.Send" Category="" ClassName="Telegram.BO.Send" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="DefaultFormat">MarkdownV2</Setting>
    <Setting Target="Adapter" Name="HTTPServer">api.telegram.org</Setting>
    <Setting Target="Adapter" Name="SSLConfig">SSL</Setting>
    <Setting Target="Adapter" Name="URL">/sendMessage</Setting>
  </Item>
  <Item Name="MQTT.BO.Test" Category="" ClassName="EnsLib.MQTT.Operation.Passthrough" PoolSize="1" Enabled="false" Foreground="false" Comment="Just for Testing" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="ClientID">arn:aws:iot:eu-west-1:974893051747:thing/IRISServer1</Setting>
    <Setting Target="Adapter" Name="SSLConfigName">AWSIOT</Setting>
    <Setting Target="Adapter" Name="Topic">devices/commands/esp32_F30B2C</Setting>
    <Setting Target="Adapter" Name="Url">ssl://a1tacd7y71f63w-ats.iot.eu-west-1.amazonaws.com:8883</Setting>
    <Setting Target="Adapter" Name="Trace">0</Setting>
    <Setting Target="Adapter" Name="KeepAlive">0</Setting>
    <Setting Target="Adapter" Name="CleanSession">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">E=RF</Setting>
    <Setting Target="Adapter" Name="Timeout">5</Setting>
  </Item>
  <Item Name="MQTT.BS.Sensors" Category="" ClassName="EnsLib.MQTT.Service.Passthrough" PoolSize="1" Enabled="true" Foreground="false" Comment="Receives Sensors Information" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="ClientID">arn:aws:iot:eu-west-1:974893051747:thing/IRISServer1</Setting>
    <Setting Target="Adapter" Name="SSLConfigName">AWSIOT</Setting>
    <Setting Target="Adapter" Name="Topic">devices/sensors/#</Setting>
    <Setting Target="Adapter" Name="Url">ssl://a1tacd7y71f63w-ats.iot.eu-west-1.amazonaws.com:8883</Setting>
    <Setting Target="Host" Name="TargetConfigNames">MQTT.BO.Sensor</Setting>
    <Setting Target="Adapter" Name="Timeout">5</Setting>
  </Item>
  <Item Name="MQTT.BO.Sensor" Category="" ClassName="MQTT.BO.Sensor" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Telegram.API.Command.BS" Category="" ClassName="Telegram.API.Command.BS" PoolSize="0" Enabled="true" Foreground="false" Comment="Receives Commands from telegram WebHook" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="Telegram.BO.Sensor" Category="" ClassName="Telegram.BO.Sensor" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="MQTT.BO.LEDs" Category="" ClassName="EnsLib.MQTT.Operation.Passthrough" PoolSize="1" Enabled="true" Foreground="false" Comment="Just for Testing" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="ClientID">arn:aws:iot:eu-west-1:974893051747:thing/IRISServer1</Setting>
    <Setting Target="Adapter" Name="SSLConfigName">AWSIOT</Setting>
    <Setting Target="Adapter" Name="Topic">devices/commands/esp32_F30B2C</Setting>
    <Setting Target="Adapter" Name="Url">ssl://a1tacd7y71f63w-ats.iot.eu-west-1.amazonaws.com:8883</Setting>
    <Setting Target="Adapter" Name="Trace">0</Setting>
    <Setting Target="Host" Name="AlertOnError">1</Setting>
    <Setting Target="Adapter" Name="Timeout">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">E=RF</Setting>
    <Setting Target="Adapter" Name="TraceLevel">3</Setting>
    <Setting Target="Adapter" Name="QOS">1</Setting>
    <Setting Target="Adapter" Name="Retained">0</Setting>
    <Setting Target="Host" Name="RetryInterval">1</Setting>
  </Item>
  <Item Name="WebinarIOT.BP.LED" Category="" ClassName="WebinarIOT.BP.LED" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="WebinarIOT.BP.Enrutador" Category="" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">WebinarIOT.BP.EnrutadorRoutingRule</Setting>
  </Item>
  <Item Name="BoTest2" Category="" ClassName="EnsLib.MQTT.Operation.Passthrough" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
