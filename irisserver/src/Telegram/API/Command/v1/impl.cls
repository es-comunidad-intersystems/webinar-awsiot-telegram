/// Telegram Notification Commands API<br/>
/// Business logic class defined by OpenAPI in Telegram.API.Command.v1.spec<br/>
/// Updated Sep 24, 2020 11:01:21
Class Telegram.API.Command.v1.impl Extends %REST.Impl [ ProcedureBlock ]
{

/// The Secret we've given the Telegram WebHook
Parameter Secret = "SnVzdEVub3VnaFRvRm9vbFlvdQ";

/// If ExposeServerExceptions is true, then details of internal errors will be exposed.
Parameter ExposeServerExceptions = 0;

Parameter APIBS = "Telegram.API.Command.BS";

/// Guarda la información sobre la acción<br/>
/// The method arguments hold values for:<br/>
///     BotName<br/>
///     updateMsg, Mensaje Update con información de Mensaje de texto<br/>
ClassMethod getNotificationByDataEntered(BotName As %String, updateMsg As %Stream.Object) As %DynamicObject
{
    #dim tResponse as Telegram.Msg.NoticeRes=##class(Telegram.Msg.NoticeRes).%New() 
    
    ///PYD+
    set ^PYD($i(^PYD))=""
    set ^PYD(^PYD,"Botname")=$g(BotName)
    set ^PYD(^PYD,"msg")=updateMsg.Read()
    do updateMsg.Rewind()
    merge ^PYD(^PYD,"data")=%request.Data
    ///PYD-
    
    if $get(%request.Data("secret",1))'=..#Secret {
	    set HTTPError=403
    }
    ///PYD-
    
	set jsonOut = ""
	set updateMsgJSON = {}.%FromJSON(updateMsg.Read())
	set tCommand = updateMsgJSON.message.text
	set tChatId = updateMsgJSON.message.chat.id
	set tUserId = updateMsgJSON.message.from.id
	set tReplyMsg = updateMsgJSON.message."message_id"
	
	set HTTPError = ""
	
	// Accept only messages that start with "/", just in case the bot reads all messages
	// Also save first part of the command, in cases with multiple bots in the same chat
	// the command is i.e. "/command@bot_name"
	set tCommand = $p(tCommand,"@",1)
	if $e(tCommand) '= "/" {
		set HTTPError = "400"
	}
	
	if HTTPError="" {
		try {
			set tRequest=##class(Telegram.Msg.DirectDeliverReq).%New()
			set tRequest.Command = $piece(tCommand," ",1)  //PYD 
			set tRequest.Parameters=$zconvert($piece(updateMsgJSON.message.text," ",2,999),"l")  ///Everything after command : /command@botparam1 param2
			
			set tRequest.DataTarget = ##class(Telegram.Utils).GetDataTarget(tRequest.Command)
			set ^PYD(^PYD,"Command")=tRequest.Command
			set ^PYD(^PYD,"DataTarget")=tRequest.DataTarget
			
			
			set tRequest.ReplyId = tReplyMsg
			set tRequest.Silent = 1
			set tRequest.ChatId = tChatId
			set tRequest.UserId = tUserId
			set tRequest.Token = ##class(Telegram.Utils).GetTokenBot(BotName)
			//Do specific actions if command is internal
			if ("internal"=$zcvt(tRequest.DataTarget,"L")) { 
				do ##class(Telegram.Utils).GetInternalCommandsText(.tRequest)
			}
			
	        // Check if the chat or user is an approved Subscriber.
	        // Allow command if it is internal command (i.e. /chatid)
			if ((##class(Telegram.Utils).IsUserApproved(tChatId, tUserId))||("internal"=$zcvt(tRequest.DataTarget,"L"))) {

				$$$ThrowOnError(##class(Ens.Director).CreateBusinessService(..#APIBS,.tService))

				do tService.OnProcessInput(tRequest,.tResponse)
				if $isobject(tResponse)
				{
					do tResponse.%JSONExportToStream(.stream)
					set formatter = ##class(%JSON.Formatter).%New()
					do formatter.FormatToStream(stream,.jsonOut)
					set HTTPError = "200"
				}else{
					set HTTPError = "404"
				}
			}else{
				set HTTPError = "403" 
			}
		} catch errObj {
			set ^PYD($i(^PYD),"error")=errObj.DisplayString()
			#dim errObj as %Exception.AbstractException
			set HTTPError = "500"
			Do ..%SetStatusCode("500")
		} 
		
	}
	// Should be defined the correct error, but Telegram keeps sending the same message if it does not receive a 200OK
	Do:HTTPError'="500" ..%SetStatusCode("200")
	
	// trace commands:
	set ^Notice.Command($zdt($h,8)) = BotName_"|"_HTTPError_"|"_updateMsgJSON.%ToJSON()
	
    Quit jsonOut
}

}
