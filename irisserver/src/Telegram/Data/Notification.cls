Class Telegram.Data.Notification Extends %Persistent
{

/// Topic notified
Property Topic As %String;

/// ID of the element notified
Property Element As %String;

/// Business Operation which notified
Property BusinessOperation As %String;

/// Notification type. Possible values: PULL for Direct notifications or PUSH for subscriber based notifications
Property NotificationType As %String;

/// Subscribier who was notified. Only filled if it is a PUSH notification
Property Subscriber As %String;

/// Direct Data where the notification was sent. Only filled if it is a PULL notification
Property DirectData As %String(MAXLEN = 512);

/// Text sent in the notification
Property Text As %String(MAXLEN = 4096);

/// Datetime when the notification was sent
Property Date As %TimeStamp;

/// Result of the notification
Property Result As %String;

/// Save the JSON response from the Sender if the Result is "ERROR"
Property Error As %String(MAXLEN = "");

ClassMethod IsPublished(pSubscriberDeliver As Notice.Messages.SubscriberDeliverReq) As %Boolean
{
	Set result = 0
	try {
		&sql(
			SELECT count(*) INTO :count
			FROM Notice.Notification
			WHERE NotificationType = 'PUSH'
			AND Result = 'OK'
			AND Subscriber = :pSubscriberDeliver.Name
			AND Element = :pSubscriberDeliver.Notice.Element
			AND Topic = :pSubscriberDeliver.Notice.Topic
		)
		if count>0 Set result = 1
	} catch Ex {
		; Nada
	}
	Quit result
}

Storage Default
{
<Data name="NotificationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Topic</Value>
</Value>
<Value name="3">
<Value>Element</Value>
</Value>
<Value name="4">
<Value>BusinessOperation</Value>
</Value>
<Value name="5">
<Value>NotificationType</Value>
</Value>
<Value name="6">
<Value>Subscriber</Value>
</Value>
<Value name="7">
<Value>DirectData</Value>
</Value>
<Value name="8">
<Value>Text</Value>
</Value>
<Value name="9">
<Value>Date</Value>
</Value>
<Value name="10">
<Value>Result</Value>
</Value>
<Value name="11">
<Value>Error</Value>
</Value>
</Data>
<DataLocation>^Telegram.Data.NotificationD</DataLocation>
<DefaultData>NotificationDefaultData</DefaultData>
<IdLocation>^Telegram.Data.NotificationD</IdLocation>
<IndexLocation>^Telegram.Data.NotificationI</IndexLocation>
<StreamLocation>^Telegram.Data.NotificationS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
