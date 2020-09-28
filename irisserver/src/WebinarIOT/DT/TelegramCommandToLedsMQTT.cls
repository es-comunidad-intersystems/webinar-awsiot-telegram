Class WebinarIOT.DT.TelegramCommandToLedsMQTT Extends Ens.DataTransformDTL [ DependsOn = (Telegram.Msg.DirectDeliverReq, MQTT.Msg.LedsRequest) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='Telegram.Msg.DirectDeliverReq' targetClass='MQTT.Msg.LedsRequest' create='new' language='objectscript' >
<annotation>Extraer los Parametros del Comando Telegram para asignar el valor de los Leds  Enviar a MQTT</annotation>
<if condition='$piece(source.Parameters," ",1)="rojo"' >
<true>
<assign value='$piece(source.Parameters," ",2)' property='target.Red' action='set' />
</true>
<false>
<if condition='$piece(source.Parameters," ",1)="azul"' >
<true>
<assign value='$piece(source.Parameters," ",2)' property='target.Blue' action='set' />
</true>
</if>
</false>
</if>
</transform>
}

}
