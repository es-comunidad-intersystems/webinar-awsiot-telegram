/// Un Mensaje para poder transformar el estado de los LEDs
Class MQTT.Msg.LedsRequest Extends (Ens.Request, %JSON.Adaptor) [ Language = objectscript ]
{

/// el Led Rojo
Property Red As %String;

Property Blue As %String;

Storage Default
{
<Data name="LedsRequestDefaultData">
<Subscript>"LedsRequest"</Subscript>
<Value name="1">
<Value>Red</Value>
</Value>
<Value name="2">
<Value>Blue</Value>
</Value>
</Data>
<DefaultData>LedsRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
