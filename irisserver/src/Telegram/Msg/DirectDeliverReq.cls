Class Telegram.Msg.DirectDeliverReq Extends Ens.Request
{

/// Text to be delivered
Property Text As %String(MAXLEN = 4096);

/// Bot Token
Property Token As %String;

/// Chat ID
Property ChatId As %String;

/// User ID (sender of the message)
Property UserId As %String;

/// ID of the message to reply to
Property ReplyId As %String;

/// When true, message causes no sound
Property Silent As %Boolean;

/// Topic where the notification will be thrown at
Property Topic As %String;

/// Target where the Data is retrived
Property DataTarget As %String;

/// Command received through the API.NOT.Command 
Property Command As %String;

/// PYD: the Parameters for the Command
Property Parameters As %String;

/// Error occurred
Property Error As %String(MAXLEN = 4096);

Storage Default
{
<Data name="DirectDeliverReqDefaultData">
<Subscript>"DirectDeliverReq"</Subscript>
<Value name="1">
<Value>Text</Value>
</Value>
<Value name="2">
<Value>Token</Value>
</Value>
<Value name="3">
<Value>ChatId</Value>
</Value>
<Value name="4">
<Value>UserId</Value>
</Value>
<Value name="5">
<Value>ReplyId</Value>
</Value>
<Value name="6">
<Value>Silent</Value>
</Value>
<Value name="7">
<Value>Topic</Value>
</Value>
<Value name="8">
<Value>DataTarget</Value>
</Value>
<Value name="9">
<Value>Command</Value>
</Value>
<Value name="10">
<Value>Error</Value>
</Value>
<Value name="11">
<Value>Parameters</Value>
</Value>
</Data>
<DefaultData>DirectDeliverReqDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
