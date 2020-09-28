/// Sends Messages to All Susbcribers of a Topic
Class Telegram.BP.Publisher Extends Ens.BusinessProcessBPL [ ClassType = persistent, ProcedureBlock ]
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Telegram.Msg.NoticeReq' response='Telegram.Msg.NoticeRes' height='2000' width='2000' >
<sequence xend='200' yend='350' >
<code name='Buscar y llamar suscriptores' xpos='200' ypos='250' >
<![CDATA[ Set subscribers = ""
 do ##class(Telegram.Utils).FindSubscribers(request.Topic, .subscribers)
  Set key=$Order(subscribers(""))
 While (key'="") {
   	Set deliveryReq = ##class(Telegram.Msg.SubscriberDeliverReq).%New()
	Set deliveryReq.Notice = request
	Set deliveryReq.Name = ##class(Telegram.Utils).GetSubscriber(key).Name
	Set deliveryReq.Target = ##class(Telegram.Utils).GetSubscriber(key).Target
	if request.SendIfPublished="Y" || '##class(Telegram.Data.Notification).IsPublished(deliveryReq) {
	    do process.SendRequestAsync(deliveryReq.Target,deliveryReq,.response)
	}
	Set key = $Order(subscripters(key))
	
 }
 ]]>
</code>
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
