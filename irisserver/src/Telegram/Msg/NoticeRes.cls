Class Telegram.Msg.NoticeRes Extends (Ens.Response, %JSON.Adaptor)
{

Property result;

Storage Default
{
<Data name="NoticeResDefaultData">
<Subscript>"NoticeRes"</Subscript>
<Value name="1">
<Value>result</Value>
</Value>
</Data>
<DefaultData>NoticeResDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
