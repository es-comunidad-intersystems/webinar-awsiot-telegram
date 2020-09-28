/// The data for all sensors on a device at a given timestamp
Class MQTT.Data.Device Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ Language = objectscript ]
{

/// Self Explanatory...
Property deviceId As %String;

Property instant As %Library.PosixTime;

Property temperature As %Float;

Property humidity As %Float;

Index BMEIndex [ Extent, Type = bitmap ];

Index IxDevice On deviceId [ Type = bitmap ];

Index IxInstant On instant;

Storage Default
{
<Data name="DeviceDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>deviceId</Value>
</Value>
<Value name="3">
<Value>instant</Value>
</Value>
<Value name="4">
<Value>temperature</Value>
</Value>
<Value name="5">
<Value>humidity</Value>
</Value>
</Data>
<DataLocation>^MQTT.Data.DeviceD</DataLocation>
<DefaultData>DeviceDefaultData</DefaultData>
<IdLocation>^MQTT.Data.DeviceD</IdLocation>
<IndexLocation>^MQTT.Data.DeviceI</IndexLocation>
<StreamLocation>^MQTT.Data.DeviceS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
