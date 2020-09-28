Class Telegram.Msg.SubscriberDeliverReq Extends Ens.Request
{

/// Production target where we will send the request
Property Target As %String;

/// Subscriptor name
Property Name As %String;

/// Notice with the info to notify
Property Notice As Telegram.Data.NoticeReq;

Storage Default
{
<Data name="SubscriberDeliverReqDefaultData">
<Subscript>"SubscriberDeliverReq"</Subscript>
<Value name="1">
<Value>Target</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Notice</Value>
</Value>
</Data>
<DefaultData>SubscriberDeliverReqDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
