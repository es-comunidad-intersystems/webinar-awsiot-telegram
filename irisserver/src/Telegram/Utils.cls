Class Telegram.Utils
{

/// Lookup table with the config for each topic: 
/// Contains a JSON with Message Template and the BotName(the Key in  lookup table Telegram_Bot_Config)
/// eg: {"template":"Hace *##TEMP##* grados, y ##HUMIDITY##% de Humedad", "botname":"IRIS_MQTT_bot"}
Parameter TopicsConfigTable = "Telegram_Topic_Config";

/// Lookup table to Map the Bot Commands to Business Operations (or Processes) that realize the Action
/// or obtain the data for the give Bot Command
/// eg: /chatid  -> "Internal" (which is a special value treated separately)
///     /state   -> WebinarIOT.IOTDevice.BO.State()
Parameter CommandTargetTable = "Telegram_Command_Target";

/// Lookup table with the token for each bot
/// For a give BotName, this contains the key to use in its final telegram format (prepended with "bot")
/// eg: IRIS_MQTT_BOT -> botXyzabcdfgs
Parameter BotConfigTable = "Telegram_Bot_Config";

Parameter TopicErrorComand = "Errors.Command";

Parameter TopicErrorNotAvailable = "Errors.NotAvailable";

Parameter DefaultDomainName = "Notice";

/// Retrieve the template text for a topic
ClassMethod GetTemplateText(topic As %String) As %String
{
	set template = ""
	set topicConfJSON = ##class(Ens.Util.FunctionSet).Lookup(..#TopicsConfigTable, topic, "")
	set topicConf = {}.%FromJSON(topicConfJSON)
	set:$IsObject(topicConf) template = topicConf.template
	quit template
}

/// Retrieve the format for a topic
ClassMethod GetFormatByTopic(topic As %String) As %String
{
	set format = ""
	//ADP
		quit:topic="" format
	set topicConfJSON = ##class(Ens.Util.FunctionSet).Lookup(..#TopicsConfigTable, topic, "")
	set topicConf = {}.%FromJSON(topicConfJSON)
	set:$IsObject(topicConf) format = topicConf.format
	quit format
}

/// Retrieve the Token for a topic
ClassMethod GetTokenByTopic(topic As %String) As %String
{
	set token = ""
	set topicConfJSON = ##class(Ens.Util.FunctionSet).Lookup(..#TopicsConfigTable, topic, "")
	set topicConf = {}.%FromJSON(topicConfJSON)
	set:$IsObject(topicConf) token = ..GetTokenBot(topicConf.botname)
	quit token
}

/// Retrieve the target BO (where SQL resides) for a command
ClassMethod GetDataTarget(command As %String) As %String
{
	Quit ##class(Ens.Util.FunctionSet).Lookup(..#CommandTargetTable, command, "")
}

/// Retrieve the token for a given Bot name
ClassMethod GetTokenBot(BotName As %String) As %String
{
	Quit ##class(Ens.Util.FunctionSet).Lookup(..#BotConfigTable, BotName, "")
}

/// Get the final text for a topic. It retrieves the template from the LookUp table
/// Replace the tags for the input parameters ARRAY
ClassMethod GetTextParamsArray(topic As %String, ByRef params) As %String
{
	Set template = ..GetTemplateText(topic)
	Set text = template
	
	Set text = $replace(text, "##ENTER##", $char(10))

	if $g(params("HORA"))="" {
		Set text = $replace(text, "##TIME##", $ztime($p($h,",",2),2)) //i.e "19:12"
	}
	if $g(params("FECHA"))="" {
		Set text = $replace(text, "##DATE##", $zdate($h,2)) //i.e "18 Jun 2020"
	}
	if $g(params("FECHAHORA"))="" {
		Set text = $replace(text, "##DATETIME##", $zdatetime($h,2,2)) //i.e "18 Jun 2020 19:12"
	}
		
	set key=""
	do {
		set key = $order(params(key))
		if key="" quit
		Set text = $replace(text, "##"_key_"##", $g(params(key)))
	}while key '= ""
	
	set text = ..RemoveNotUsedTags(text)
	if ..GetFormatByTopic(topic)'="HTML" set text = ..FormatText(text)
	
	Quit text
}

/// Get the final text for a topic. It retrieves the template from the LookUp table
/// Replace the tags for the input parameters ARRAY
ClassMethod GetInternalCommandsText(ByRef msg As Notice.Messages.DirectDeliverReq) As %Status
{
	set tSC = $$$OK
	if msg.Command = "/chatid"
	{
		set text = "The ID of this Chat is: " _ msg.ChatId
	}
	elseif msg.Command = "/senderid"
	{
		set text = "The ID of the Sender is: " _ msg.UserId
	}
	
	set msg.Text = ..FormatText(text)
	
	Quit tSC
}

/// Replace characters to adapt to sender restrictions
ClassMethod FormatText(text As %String) As %String
{
	// In all other places characters 
	// '_', '*', '[', ']', '(', ')', '~', '`', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!' 
	// must be escaped with the preceding character '\'.
	set text = $replace(text, "[", "\[")
	set text = $replace(text, "]", "\]")
	set text = $replace(text, "(", "\(")
	set text = $replace(text, ")", "\)")
	set text = $replace(text, "~", "\~")
	set text = $replace(text, "`", "\`")
	set text = $replace(text, ">", "\>")
	set text = $replace(text, "#", "\#")
	set text = $replace(text, "+", "\+")
	set text = $replace(text, "-", "\-")
	set text = $replace(text, "=", "\=")
	set text = $replace(text, "|", "\|")
	set text = $replace(text, "{", "\{")
	set text = $replace(text, "}", "\})")
	set text = $replace(text, ".", "\.")
	set text = $replace(text, "!", "\!")
	quit text
}

/// Replace characters to adapt to sender restrictions
ClassMethod FormatCommandText(text As %String) As %String
{
	// '_', '*'
	// must be escaped with the preceding character '\'.
	set text = $replace(text, "_", "\_")
	set text = $replace(text, "*", "\*") 
	quit text
}

/// Remove all i.e. ##TAG## that weren't parsed
ClassMethod RemoveNotUsedTags(text As %String) As %String
{
	set header = "##", trailer = "##"
	set pos1 = 1, pos2 = 1, aux = 1
	set textNoTags = ""
	do {
		set pos1 = $find(text,header,pos2)
		if pos1'=0 {
			set aux = $find(text,trailer,pos1)
			if aux'=0 {
				set textNoTags = textNoTags _ $extract(text,pos2, pos1-$l(header)-1)
			}else{
				// if trailer is not found, copy the last part of the text (at least with a wrong not closed tag) and finish looking for tags
				set textNoTags = textNoTags _ $extract(text,pos2, *)
				set pos1 = 0
			}
			set pos2 = aux
		}else{
			// if no more tags found copy the last part of the text
			set textNoTags = textNoTags _ $extract(text,pos2, *)
		}
	}while pos1 '= 0
	
	quit textNoTags
}

/// Find all the subscriberss for a topic (array with the ids)
ClassMethod FindSubscribers(topic As %String, Output subscribersList As %String) As %Status
{
	do ##class(EnsLib.PubSub.Utils).FindSubscribers(..#DefaultDomainName, topic, .subscribersList)
	Quit $$$OK
}

/// Build a EnsLib.PubSub.Subscriber by its ID
ClassMethod GetSubscriber(subscriberId As %String) As EnsLib.PubSub.Subscriber
{
	Quit ##class(EnsLib.PubSub.Subscriber).%OpenId(subscriberId)
}

/// Build a EnsLib.PubSub.Subscriber by Domain & Name
ClassMethod GetSubscriberByName(domain As %String, name As %String) As EnsLib.PubSub.Subscriber
{
	Quit ##class(EnsLib.PubSub.Subscriber).NameIdxOpen(domain, name)
}

/// Find chatId or userId in the Subscribers Address field
/// If any of these is found, the command is approved
ClassMethod IsUserApproved(chatId As %String, userId As %String) As %Boolean
{
	set approved = 0
	&sql(
		select count(*) into :approved
		from EnsLib_PubSub.Subscriber
		where Address = :chatId
		or Address = :userId
	)

	Quit approved
}

}
