/// Saves the  MQTT Sensors Data
Class MQTT.BO.Sensor Extends Ens.BusinessOperation [ Language = objectscript ]
{

Parameter INVOCATION = "Queue";

/// Appends the IOT Sensor Data to the Table
Method InsertData(pRequest As EnsLib.MQTT.Message, Output pResponse As Ens.Response) As %Status
{
	#DIM tSC as %Status=$$$OK
	#DIM errObj as %Exception.AbstractException
	#DIM tObj as %DynamicObject
	try {
		set tObj={}.%FromJSON(pRequest.StringValue) 
		set tRow=##class(MQTT.Data.Device).%New()
		set tRow.instant=##class(%PosixTime).CurrentTimeStamp()
		set tRow.deviceId=tObj.deviceId
		set tRow.temperature=tObj.temperature
		set tRow.humidity=tObj.humidity
		$$$ThrowOnError(tRow.%Save(1))
		
	}catch (errObj) {
		set tSC=errObj.AsStatus()
	}
	quit tSC
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="EnsLib.MQTT.Message"> 
		<Method>InsertData</Method>
	</MapItem>
</MapItems>
}

}
