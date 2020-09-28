/// Get Sensor Data
Class Telegram.BO.Sensor Extends Ens.BusinessOperation [ Language = objectscript ]
{

Parameter INVOCATION = "Queue";

Property Topic As %String [ InitialExpression = "Sensors" ];

/// The Telegram Topic for the Reply
Parameter SETTINGS = "Topic:Basic";

/// Get the Last Sensor Values
/// //{"template":"Hace *##TEMP##* grados, y ##HUMIDITY## de Humedad", "botname":"IRIS_MQTT"}
Method GetLast(pRequest As Telegram.Msg.DirectDeliverReq, Output pResponse As Telegram.Msg.DirectDeliverReq) As %Status
{

	
	set pResponse = ##class(Notice.Messages.DirectDeliverReq).%New()
	set pResponse.Topic = ..Topic
	
	//Quickly get the last values
	&sql(select  top 1 temperature, humidity into :temp,:hum from MQTT_Data.Device order by instant desc)
	set values("TEMP")=temp
	set values("HUMIDITY")=hum
	
	
	set pResponse.Text = ##class(Telegram.Utils).GetTextParamsArray("Sensors",.values)
	quit $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Telegram.Msg.DirectDeliverReq"> 
		<Method>GetLast</Method>
	</MapItem>
</MapItems>
}

}
