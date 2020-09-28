/// Gestiona un comando para cambiar el color de un LED
Class WebinarIOT.BP.LED Extends Ens.BusinessProcessBPL
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Telegram.Msg.DirectDeliverReq' response='Telegram.Msg.DirectDeliverReq' height='2000' width='2000' >
<context>
<property name='json' type='%String' instantiate='0' >
<annotation><![CDATA[La cadena JSON a enviar a MQTT]]></annotation>
<parameters>
<parameter name='MAXLEN'  value='1024' />
</parameters>
</property>
<property name='LedsRequest' type='MQTT.Msg.LedsRequest' instantiate='1' />
</context>
<sequence xend='200' yend='650' >
<transform name='Parametros -&gt; LEDs' class='WebinarIOT.DT.TelegramCommandToLedsMQTT' source='request' target='context.LedsRequest' xpos='200' ypos='250' />
<code name='Transformar a JSON' xpos='200' ypos='350' >
<![CDATA[ do context.LedsRequest.%JSONExportToString(.jsonObj)
 set context.json=jsonObj
 $$$TRACE(jsonObj)]]>
</code>
<call name='Cambiar LEDs' target='MQTT.BO.LEDs' async='1' xpos='200' ypos='450' >
<annotation><![CDATA[Llama a BO de MQTT para Cambiar Estado Leds]]></annotation>
<request type='EnsLib.MQTT.Message' >
<assign property="callrequest.StringValue" value="context.json" action="set" />
</request>
<response type='Ens.Response' />
</call>
<sequence name='Preparar Respuesta' xpos='200' ypos='550' xend='200' yend='450' >
<annotation><![CDATA[Rellenar Text y Topic]]></annotation>
<assign name="Topic de Respuesta" property="response.Topic" value="&quot;LEDs&quot;" action="set" xpos='200' ypos='250' />
<assign name="Texto de Respuesta" property="response.Text" value="&quot;Cambio realizado&quot;" action="set" xpos='200' ypos='350' />
</sequence>
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
