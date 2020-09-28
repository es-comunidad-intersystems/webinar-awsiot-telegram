/// A testing Class for the Telegram BO
Class Telegram.Test Extends %RegisteredObject
{

ClassMethod Run() As %Status
{
	#DIM tSC as %Status=$$$OK
	#DIM errObj as %Exception.AbstractException
	#DIM tTestingSvc as Ens.BusinessService
	#DIM tTestingMsg as EnsLib.Testing.Process
	#DIM tMsg as Telegram.Msg.DirectDeliverReq
	
	try {
		//El Mensaje de Prueba a Enviar 
		set tMsg=##class(Telegram.Msg.DirectDeliverReq).%New()
		set tMsg.Text="This Text send from IRIS"
		set tMsg.Token="bot1382788365:AAEfV75LJnGGUfHknLUKELNeAbOO7LyT8RY"
		set tMsg.ChatId="11968498"
		set tMsg.UserId="11968498"
		set tMsg.ReplyId=""
		set tMsg.Silent=0
		set tMsg.Topic="ExtremeConditions"
		set tMsg.Command=""
		
		//El Mensaje Envoltorio para el Testing Service
		set tTestingMsg=##class(EnsLib.Testing.Request).%New()
		set tTestingMsg.Target="Telegram.BO.Send"
		set tTestingMsg.Request=tMsg
		
		//Use the Testing Service
		$$$THROWONERROR(tSC,##class(Ens.Director).CreateBusinessService("EnsLib.Testing.Service",.tTestingSvc))
		$$$THROWONERROR(tSC,tTestingSvc.ProcessInput(tTestingMsg))
	}catch (errObj) {
		Write "CATCH:",errObj.DisplayString(),!
		set tSC=errObj.AsStatus()
	}
	quit tSC
}

}
