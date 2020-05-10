#!/usr/bin/expect

set skill_id [lindex $argv 0];

spawn ask dialog -s ${skill_id} -l es-ES
expect "User"
send -- "abre hola mundo\r"
expect "Bienvenido, puedes decir Hola o Ayuda. Cual prefieres?"
send -- "hola\r"
expect "Hola Mundo!"
send -- "abre hola mundo\r"
expect "Bienvenido, puedes decir Hola o Ayuda. Cual prefieres?"
send -- "ayuda\r"
expect "Puedes decirme hola. Cómo te puedo ayudar?"
send -- "adios\r"
expect "Hasta luego!"
