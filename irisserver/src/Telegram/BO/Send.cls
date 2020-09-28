/// This is the Class to Send Messages to the Telegram Bot
/// Message can be sent directly (Unsolicited) from the Platform to the Bot or as a reply of a query made by a user to the bot
Class Telegram.BO.Send Extends (EnsLib.REST.Operation, Ens.BusinessOperation)
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

Property DefaultFormat As %String;

Parameter SETTINGS = "DefaultFormat:Basic";

/// Uses the Lookup Tables to Get the Token, and Format for a given topic, as well as the ChatId for a given Subscriber name
Method ExtractConfigInfo(name As %String, topic As %String, Output token As %String, Output chatId As %String, Output format As %String) As %Status
{
	#dim tSC as %Status = $$$OK
	#dim errObj as %Exception.AbstractException
	try {
		set tDomain = ##class(Telegram.Utils).#DefaultDomainName
		set Subscriber = ##class(Telegram.Utils).GetSubscriberByName(tDomain, name)
		if '$IsObject(Subscriber) {
			throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Subscriber not found in Lookup Table"))	
		}
		set chatId = Subscriber.Address
		set token = ##class(Telegram.Utils).GetTokenByTopic(topic)
		set format = ##class(Telegram.Utils).GetFormatByTopic(topic)
	} catch errObj {
		Set tSC = errObj.AsStatus()
	}
	Quit tSC
}

ClassMethod SaveDirectNotification(pDirectDeliver As Telegram.Msg.DirectDeliverReq, pResult As %DynamicObject) As %Status
{
	Set tSC = $$$OK
    try {
    	Set notification = ##class(Telegram.Data.Notification).%New()
    	Set notification.Topic = pDirectDeliver.Topic
    	Set notification.Element = ""
    	Set notification.BusinessOperation = "Telegram.BO.Send"
    	Set notification.NotificationType = "PULL"
    	Set notification.Subscriber = ""
    	Set notification.DirectData = pDirectDeliver.Token_"|||"_pDirectDeliver.ChatId
    	Set notification.Text = pDirectDeliver.Text
    	Set notification.Date = $zdatetime($horolog,3)   
    	Set notification.Result = $case(pResult.ok, 1:"OK", :"ERROR")
    	Set:'pResult.ok notification.Error = pResult.%ToJSON()
        $$$ThrowOnError(notification.%Save())
    } catch Ex {
    	Set tSC = Ex.AsStatus()
    }
    Quit tSC
}

ClassMethod SaveNotificationError(pSubscriberDeliver As Telegram.Msg.SubscriberDeliverReq, error As %String) As %Status
{
	Set tSC = $$$OK
    try {
    	Set notification = ##class(Telegram.Data.Notification).%New()
    	Set notification.Topic = pSubscriberDeliver.Notice.Topic    	
    	Set notification.Element = pSubscriberDeliver.Notice.Element
    	Set notification.BusinessOperation = pSubscriberDeliver.Target
    	Set notification.NotificationType = "PUSH"
    	Set notification.Subscriber = pSubscriberDeliver.Name
    	Set notification.DirectData = ""
    	Set notification.Text = pSubscriberDeliver.Notice.Text
    	Set notification.Date = $zdatetime($horolog,3)   
    	Set notification.Result = "ERROR"
    	Set notification.Error = error
        $$$ThrowOnError(notification.%Save())
    } catch Ex {
    	Set tSC = Ex.AsStatus()
    }
    Quit tSC
}

ClassMethod SaveNotification(pSubscriberDeliver As Telegram.Msg.SubscriberDeliverReq, pResult As %DynamicObject) As %Status
{
	Set tSC = $$$OK
    try {
    	Set notification = ##class(Telegra.Data.Notification).%New()
    	Set notification.Topic = pSubscriberDeliver.Notice.Topic    	
    	Set notification.Element = pSubscriberDeliver.Notice.Element
    	Set notification.BusinessOperation = pSubscriberDeliver.Target
    	Set notification.NotificationType = "PUSH"
    	Set notification.Subscriber = pSubscriberDeliver.Name
    	Set notification.DirectData = ""
    	Set notification.Text = pSubscriberDeliver.Notice.Text
    	Set notification.Date = $zdatetime($horolog,3)   
    	Set notification.Result = $case(pResult.ok, 1:"OK", :"ERROR")
    	Set:'pResult.ok notification.Error = pResult.%ToJSON()
        $$$ThrowOnError(notification.%Save())
    } catch Ex {
    	Set tSC = Ex.AsStatus()
    }
    Quit tSC
}

/// this Send Unsolicited Messages to Subscribers of Topics
Method sendMessage(pRequest As Telegram.Msg.SubscriberDeliverReq, Output pResponse As Telegram.Msg.SubscriberDeliverRes) As %Status
{
	#dim tSC as %Status = $$$OK
	#dim errObj as %Exception.AbstractException
	Set tResponse = ""
	Set result = "OK"
	try {
		Set textNotify = pRequest.Notice.Text
		Set botToken = ""
		Set chatID = ""
		Set format = ""
		
		$$$ThrowOnError(..ExtractConfigInfo(pRequest.Name, pRequest.Notice.Topic, .botToken, .chatID,.format))
		$$$TRACE("Got Config Info, chatID:"_chatID)
		$$$ThrowOnError(..SendRESTRequest(textNotify, format, botToken, chatID,,, .tResponse))
		$$$ThrowOnError(..SaveNotification(pRequest, tResponse))
	} catch errObj {
		set tSC=errObj.AsStatus()
		do ..SaveNotificationError(pRequest, errObj.DisplayString())
	}
	
	Set pResponse = ##class(Telegram.Msg.SubscriberDeliverRes).%New()
	Set pResponse.result = result
	
	Quit tSC
}

/// This Sends a Message as A Reply to a Request made to a bot.
Method sendMessageDirect(pRequest As Telegram.Msg.DirectDeliverReq, Output pResponse As Telegram.Msg.SubscriberDeliverRes) As %Status
{
	#dim tSC as %Status = $$$OK
	#dim errObj as %Exception.AbstractException
	Set tResponse = ""
	Set result = "OK"
	try {
		Set textNotify = pRequest.Text
		Set chatID = pRequest.ChatId 
		set replyID = pRequest.ReplyId
		Set Silent = pRequest.Silent
		if pRequest.Token = "" {
			set botToken = ##class(Telegram.Utils).GetTokenByTopic(pRequest.Topic)
		}else{ set botToken = pRequest.Token }
		set format=##class(Telegram.Utils).GetFormatByTopic(pRequest.Topic)
		$$$ThrowOnError(..SendRESTRequest(textNotify, format, botToken, chatID, replyID, Silent, .tResponse))
		$$$ThrowOnError(..SaveDirectNotification(pRequest, tResponse))
	} catch errObj {
		set tSC=errObj.AsStatus()
		//ADP
		if $IsObject(tResponse) {
			set result = $case(tResponse.ok, 1:"OK", :"ERROR")
			do ..SaveDirectNotification(pRequest, tResponse)
		}else{
			set result = "ERROR"
			
		}
	}
	
	Set pResponse = ##class(Notice.Messages.SubscriberDeliverRes).%New()
	Set pResponse.result = result
	
	Quit tSC
}

Method SendRESTRequest(pText As %String, pFormat As %String, pBotToken As %String, pChatID As %String, pReplyId As %String = "", pSilent As %Boolean = 0, Output pResponse As %RegisteredObject) As %Status
{
	set tSC = $$$OK
	
	try  {
		$$$TRACE("SendRESTRequest")
		$$$ThrowOnError(..SetRequest(pText, pFormat, pChatID, pReplyId, pSilent, .request))
		
		//PYD: Do not use the API Manager.
		///$$$ThrowOnError(..SetXAuthToken(.request, pBotToken))
		set tURL=pBotToken_""_..Adapter.URL
		//
		$$$TRACE("Before SendFormDataURL")
		$$$ThrowOnError(..Adapter.SendFormDataURL(tURL,.tResponse,"POST",request))
     	$$$TRACE("SizeResponseData:"_tResponse.Data.SizeGet())
		$$$TRACE("JSON respuesta:"_tResponse.Data.Read()) d tResponse.Data.Rewind()
		set pResponse = {}.%FromJSON(tResponse.Data)
	} catch errObj {
		set tSC=errObj.AsStatus()
		$$$LOGERROR(tResponse.Data.Read()) d tResponse.Data.Rewind()
		set pResponse = {}.%FromJSON(tResponse.Data)
	}
	Quit tSC
}

/*
Method SetXAuthToken(ByRef pHTTPRequest As %Net.HttpRequest, pBotToken As %String) As %Status
{
	set tSC = pHTTPRequest.SetHeader(..#AuthHeader, pBotToken)
	quit tSC
}
*/
Method SetRequest(pText As %String, pFormat As %String, pChatID As %String, pReplyId As %String = "", pSilent As %Boolean = 0, ByRef pHTTPRequest As %Net.HttpRequest) As %Status
{
	set tSC = $$$OK
	
	try {
		set json = {}
		set json."chat_id" = pChatID
		set json.text = pText
		set:pReplyId'="" json."reply_to_message_id" = pReplyId
		set json."disable_notification" = pSilent
		set json."parse_mode" = $case(pFormat,"":..DefaultFormat,:pFormat)
		set jsonString = json.%ToJSON()
		
		$$$TRACE("JSON salida:"_jsonString)
		set pHTTPRequest = ##class(%Net.HttpRequest).%New()
		set pHTTPRequest.ContentType = "application/json"
		set pHTTPRequest.ContentCharset = "UTF-8"
		$$$ThrowOnError(pHTTPRequest.EntityBody.Write(jsonString))
	} catch errObj {
		set tSC=errObj.AsStatus()
	}
	
	quit tSC
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Telegram.Msg.SubscriberDeliverReq"> 
		<Method>sendMessage</Method>
	</MapItem>
	<MapItem MessageType="Telegram.Msg.DirectDeliverReq"> 
		<Method>sendMessageDirect</Method>
	</MapItem>
</MapItems>
}

}
