#META {"start":1}
# Riproduce un suono sul buzzer integrato quando arriva un comando via
# MQTT. Pensato per essere richiamato da Home Assistant (vedi lo script
# gateway_zigbee_suono in scripts.yaml, che pubblica su questo topic).
#
# Diagnosticato: connessione e subscribe risultavano sempre "true" ma i
# messaggi non arrivavano mai (log "RICEVUTO" mai comparso), pur con
# Home Assistant che pubblicava correttamente sullo stesso broker
# (verificato con "Ascolta un argomento"). Il dispositivo ha
# un'integrazione MQTT con "Topic base: zhub" configurata sull'utente
# mqttmanager: sospetto un ACL sul broker che limita quell'utente a
# zhub/# e scarta silenziosamente i messaggi fuori da li'. Spostato il
# topic sotto zhub/ per lavorare con l'ACL invece che contro.
#
# Topic: zhub/suono (e, per sicurezza, anche con lo slash iniziale).
# Payload atteso: campanello | allerta | errore | successo | sirena
#
# Richiede l'integrazione TELEGRAM già configurata da
# Scripts -> Integrations (bot token + chat id).

import MQTT
import BUZZER
import TELEGRAM

var TOPIC = "zhub/suono"
var TOPIC_SLASH = "/" .. TOPIC

var melodie = {
  "campanello": "Campanello:d=8,o=5,b=120:e6,c6",
  "allerta": "Allerta:d=8,o=5,b=160:c6,p,c6,p,c6,p",
  "errore": "Errore:d=8,o=5,b=120:c6,a#5,g5,c5",
  "successo": "Successo:d=8,o=5,b=140:c5,e5,g5,c6",
  "sirena": "Sirena:d=8,o=5,b=140:c6,g5,c6,g5,c6,g5"
}

SLZB.log("buzzer_mqtt: avvio, mi connetto al broker...")
var connected = MQTT.waitConnect(30)
SLZB.log("buzzer_mqtt: waitConnect(30) ha restituito " .. str(connected) .. ", isConnected() = " .. str(MQTT.isConnected()))

var sub1 = MQTT.subscribeCustom(TOPIC)
var sub2 = MQTT.subscribeCustom(TOPIC_SLASH)
SLZB.log("buzzer_mqtt: subscribe '" .. TOPIC .. "' -> " .. str(sub1) .. ", subscribe '" .. TOPIC_SLASH .. "' -> " .. str(sub2))

def on_msg(topic, data)
  SLZB.log("buzzer_mqtt: RICEVUTO topic='" .. topic .. "' payload='" .. data .. "'")
  var suono = melodie.find(data)
  if suono == nil
    SLZB.log("buzzer_mqtt: suono sconosciuto '" .. data .. "'")
    TELEGRAM.send("[Gateway Zigbee] Buzzer: ricevuto suono sconosciuto '" .. data .. "'.")
  else
    SLZB.log("buzzer_mqtt: riproduco '" .. data .. "'")
    TELEGRAM.send("[Gateway Zigbee] Buzzer: suono '" .. data .. "' in riproduzione.")
    BUZZER.play(suono)
  end
end

MQTT.on_message(on_msg)
SLZB.log("buzzer_mqtt: pronto, in ascolto")
