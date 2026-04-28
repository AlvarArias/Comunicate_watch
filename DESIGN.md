# Comunicate_watch — Documento de Diseño

## 1. Visión general


App de mensajería para Apple Watch que permite enviar mensajes de texto cortos entre 2 usuarios sin necesitar el iPhone.
Los uusuarios son dos personas conectadas a traves de la app, son usuarios de la app que buscan comunicarse.



## 2. Flujos de usuario

<!-- Diagrama simple de navegación entre pantallas. Ejemplo:
Pantalla Login → Pantalla Principal → Pantalla Chat
                                    → Pantalla Configuración
                                    
-->

## 3. Pantallas

### Pantalla Login
- **Muestra:** 
- Botón Login Google Acount
- Botón Login Apple Account
- Botón Login user, password 
- Boton (opcion de crear user, password)
  
- **Acciones:** (qué puede hacer el usuario)
- Hace click en el boton de Google, Apple o user & password.
- Hacke click  en el boton de crear usuario, password. 

- **Resultado:** (qué pasa después de cada acción)
- Si es confirmado muestra la pantalla principal
- Si no se obtiene la confirmacion mostar un mensaje de login fallido y vuelve a la pantalla de login.
- Crea user y password y luego volver a la pantalla de login.


### Pantalla Principal

- **Muestra:**
  - Botón "Crear sala" (genera un código de invitación)
  - Campo para introducir código de invitación de otro usuario
  - Lista de chats activos (si ya hay conversaciones existentes)

- **Acciones:**
  - Pulsar "Crear sala" → genera un código corto (4-6 caracteres) visible en pantalla
  - Introducir código de otra persona → unirse a su sala
  - Seleccionar un chat existente → ir a la Pantalla Chat

- **Resultado:**
  - Al crear sala: el código se guarda en Firestore con el UID del usuario y una expiración de ~10 minutos. Se muestra el código para que el otro usuario lo introduzca.
  - Al introducir código válido: el sistema resuelve los dos UIDs, crea un `chatId` permanente (`uid1_uid2` ordenados alfabéticamente) y navega directamente al chat.
  - Al introducir código inválido o expirado: muestra mensaje de error y vuelve a la pantalla principal.

- **Notas técnicas:**
  - Estructura en Firestore:
    - `invites/{code}` → `{ ownerUID, expiresAt }` (se elimina tras el emparejamiento)
    - `chats/{uid1_uid2}/messages/` → mensajes del chat permanente
  - El `chatId` se genera siempre igual: `[uidA, uidB].sorted().joined(separator: "_")`, evitando duplicados independientemente de quién inicia la conexión.

### Pantalla Chat

- **Muestra:**
  - Lista de mensajes de la conversación (texto + hora + remitente)
  - Campo de texto para escribir mensaje
  - Botón enviar

- **Acciones:**
  - Escribir y enviar un mensaje
  - Desplazarse por el historial de mensajes

- **Resultado:**
  - El mensaje se guarda en `chats/{chatId}/messages/` en Firestore
  - El listener en tiempo real (`addSnapshotListener`) actualiza la lista automáticamente en ambos dispositivos
  - El receptor recibe una notificación APNs si la app está en segundo plano

### Pantalla Configuración

- **Muestra:** (qué elementos aparecen en pantalla)
- **Acciones:** (qué puede hacer el usuario)
- **Resultado:** (qué pasa después de cada acción)

<!-- Repite este bloque por cada pantalla -->

## 4. Modelo de datos

<!-- Qué información maneja la app. No necesita ser técnico. Ejemplo:
- **Usuario:** nombre, foto, ID
- **Mensaje:** texto, fecha, quién lo envió, quién lo recibió
- **Conversación:** lista de mensajes entre dos usuarios
-->

## 5. Integraciones externas

<!-- Qué servicios usa la app y para qué exactamente. Ejemplo:
- **Firebase Auth:** login con Google
- **Firestore:** guardar y sincronizar mensajes en tiempo real
- **APNs:** notificar al usuario cuando llega un mensaje nuevo
-->

## 6. Reglas de negocio

<!-- Lo que no es obvio visualmente. Ejemplo:
- Los mensajes tienen un límite de X caracteres
- Solo se puede chatear con usuarios que se han aceptado mutuamente
- Los mensajes no leídos se marcan con un indicador visual
-->
