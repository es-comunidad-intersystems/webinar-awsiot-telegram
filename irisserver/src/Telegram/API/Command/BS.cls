Class Telegram.API.Command.BS Extends Ens.BusinessService
{

Parameter TimeoutDataTarget = 30;

Method OnProcessInput(pInput As Telegram.Msg.DirectDeliverReq, Output pOutput As %RegisteredObject) As %Status
{
	// OnProcessInput
	$$$TRACE("Start, pInput:"_pInput.Command_"("_pInput.Parameters_") DataTarget:"_pInput.DataTarget)
	try {
		if ("internal"'=$zcvt(pInput.DataTarget,"L")) // If command not internal
		{
			if (pInput.DataTarget '="") {
				// Get Data from BP/BO
				set tSC = ..SendRequestSync(pInput.DataTarget, pInput, .tRequest, ..#TimeoutDataTarget)
				
				// If tRequest.Text is Null, then there was a timeout. Send the Not Available Error text
				if (($$$ISERR(tSC))||('$IsObject(tRequest))||(tRequest.Text = "")) {
					set:'$IsObject(tRequest) tRequest = ##class(Telegram.Msg.DirectDeliverReq).%New()
					set:tRequest.Error="" tRequest.Error = $System.Status.DisplayError(tSC)
					set tTopic = ##class(Telegram.Utils).#TopicErrorNotAvailable
					set tRequest.Topic = tTopic
					set tRequest.Text = ##class(Telegram.Utils).GetTextParamsArray(tTopic)
				}
				
				// Set the retrived text & topic from the DataTarget
				set pInput.Text = tRequest.Text
				set pInput.Topic = tRequest.Topic 
			}
			else
			{
				//Error-  NO such Command in Lookup Table
				set values("COMMAND") = ##class(Telegram.Utils).FormatCommandText(pInput.Command)
				set tTopic = ##class(Telegram.Utils).#TopicErrorComand
				set pInput.Topic = tTopic
				set pInput.Text = ##class(Telegram.Utils).GetTextParamsArray(tTopic,.values)
			}
		}
		
		// Send to the notificator
		set tSC = ..SendRequestSync("Telegram.BO.Send",pInput,.pOutput,60)
	} catch errObj {
		set tSC=errObj.AsStatus()
	}  
	 
	return tSC
}

}
