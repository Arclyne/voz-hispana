--[[
	ReferralConfig

	Todo lo ajustable del sistema de invitar amigos. Este es el unico archivo que
	hay que tocar para cambiar recompensas, tiempos o limites.

	Como funciona el sistema, en corto:

	1. Alguien entra por un link: el de invitar amigos de Roblox
	   (ReferredByPlayerId), o un share link / deep link que lleve dentro a quien
	   invita (LaunchData). Tambien cuenta unirse a un amigo que ya esta en el
	   servidor. Nadie escribe nada en ningun momento. Solo cuenta si es su
	   primera vez y si pasa el chequeo de chat de voz (al que echan por no tener
	   micro no cuenta).
	2. Tiene PendingWindowSeconds (2 dias) para jugar RequiredSeconds (15 min).
	   Con AccumulateAcrossSessions los minutos se acumulan entre sesiones; sin
	   el, tienen que ser de una sentada.
	3. Al completarlos, el invitador suma +1 amigo de por vida y se le desbloquea
	   el hito que corresponda en la escalera de abajo.
]]

local ReferralConfig = {}

-- Interruptor general. En false no se registra ninguna invitacion nueva; las
-- que ya estan en curso siguen su camino.
ReferralConfig.Enabled = true

ReferralConfig.Settings = {
	-- Minutos que tiene que jugar el invitado.
	RequiredSeconds = 15 * 60,

	--[[
		Como se cuentan esos minutos.

		true  = se acumulan durante los 2 dias. Entra, juega 5 minutos, se va, y
		        cuando vuelva sigue por donde iba.
		false = tienen que ser de una sentada. Si se desconecta mas de
		        ReconnectGraceSeconds, vuelve a empezar de cero.

		Acumular convierte muchas mas invitaciones; de una sentada es mas dificil
		de falsear. Con el chat de voz obligatorio y la cuenta minima, acumular
		sale bien parado.
	]]
	AccumulateAcrossSessions = true,

	-- Cuanto vive la invitacion en "en progreso" antes de caducar sin premio.
	PendingWindowSeconds = 48 * 60 * 60,

	-- Margen para que un teleport entre places (casa, evento, karaoke) o una
	-- reconexion rapida no cuenten como haberse ido. Solo importa cuando
	-- AccumulateAcrossSessions esta en false.
	ReconnectGraceSeconds = 90,

	-- Cada cuantos segundos de juego se persiste el avance para que el invitador
	-- vea moverse el anillo. Mas bajo = barra mas fina y mas escrituras.
	ProgressCheckpointSeconds = 180,

	-- Antiguedad minima de la cuenta del invitado, en dias. Se comprueba AL
	-- COMPLETAR, no al entrar. Ojo: con la ventana de 48 h, cualquier valor mayor
	-- que 2 deja fuera para siempre a quien se cree la cuenta para el video de un
	-- youtuber. El chat de voz ya exige cuenta verificada, que es el filtro real.
	MinAccountAgeDays = 0,

	-- Tope de invitaciones en progreso a la vez por invitador. Al pasarse se cae
	-- la mas antigua sin cobrar. Limita las lecturas de DataStore que cuesta
	-- pintar la lista de la tablet; no limita el total de amigos.
	MaxPendingPerInviter = 50,
}

--[[
	Forma de los codigos que viajan DENTRO de un link, en `launchData=ref%3DCODIGO`.
	Ya no se teclean en ningun sitio: son para armarle a mano un share link a cada
	persona contratada desde el Creator Dashboard, con un codigo corto y suyo.

	El link de un jugador normal lleva su userId, no un codigo (ver Link).
]]
ReferralConfig.Codes = {
	-- Un nombre de usuario de Roblox tambien vale como codigo, y llegan a 20.
	MinLength = 3,
	MaxLength = 20,

	-- Se normalizan a mayusculas. Solo letras, numeros y guion bajo.
	Pattern = "^[A-Z0-9_]+$",
}

--[[
	Escalera de recompensas.

	- `Id` es permanente y es por lo que se guarda lo reclamado. NUNCA reutilices
	  un Id borrado, o alguien podria reclamar dos veces.
	- `Friends` es cuantos amigos completados hacen falta.
	- Anadir, quitar o reordenar hitos es seguro: lo ya reclamado no se mueve.
	- La lista se ordena sola por `Friends`; el orden de escritura da igual.

	Las cantidades de abajo son un punto de partida, no un dogma. La logica:
	traer un amigo verificado que juega 15 minutos vale bastante mas que una
	mision diaria (25 monedas), y la curva sube para premiar la constancia, con
	saltos gordos en el 5, el 10 y el 14 para que haya metas visibles.
]]
ReferralConfig.Rewards = {
	{ Id = "m01", Friends = 1,  Currency = "Coins", Amount = 100 },
	{ Id = "m02", Friends = 2,  Currency = "Coins", Amount = 150 },
	{ Id = "m03", Friends = 3,  Currency = "Coins", Amount = 200 },
	{ Id = "m04", Friends = 4,  Currency = "Coins", Amount = 250 },
	{ Id = "m05", Friends = 5,  Currency = "Coins", Amount = 500 },
	{ Id = "m06", Friends = 6,  Currency = "Coins", Amount = 400 },
	{ Id = "m07", Friends = 7,  Currency = "Coins", Amount = 450 },
	{ Id = "m08", Friends = 8,  Currency = "Coins", Amount = 500 },
	{ Id = "m09", Friends = 9,  Currency = "Coins", Amount = 600 },
	{ Id = "m10", Friends = 10, Currency = "Coins", Amount = 1200 },
	{ Id = "m11", Friends = 11, Currency = "Coins", Amount = 700 },
	{ Id = "m12", Friends = 12, Currency = "Coins", Amount = 800 },
	{ Id = "m13", Friends = 13, Currency = "Coins", Amount = 900 },
	{ Id = "m14", Friends = 14, Currency = "Coins", Amount = 2500 },
}

--[[
	Recompensa por defecto: la tarjeta "+15" de DefaultFriendRewards.

	Es lo que se lleva cada amigo nuevo una vez agotada la escalera, para que el
	sistema no se quede sin premio con la gente que invita mucho.

	`From` se calcula solo a partir del ultimo hito si lo dejas a nil.
	`Every = 1` = cada amigo. Ponlo a 5 y sera cada cinco.
	Con `Enabled = false` la escalera simplemente se acaba en el ultimo hito.
]]
ReferralConfig.Default = {
	Enabled = true,
	From = nil,
	Every = 1,
	Currency = "Coins",
	Amount = 400,
}

--[[
	Los dos links que la tablet le da a cada jugador.

	`PlaceId` arma el link permanente, el que se copia de la tablet:
	https://www.roblox.com/games/start?placeId=<PlaceId>&launchData=ref%3D<userId>
	Tiene que ser el place de inicio, no una casa ni un evento.

	`Share` configura el link corto del menu de compartir de Roblox. Ese CADUCA:
	pasado ExpirationSeconds sigue llevando al juego, pero ya sin invitacion. Para
	la descripcion de un video va el permanente, que no caduca nunca.

	Roblox no documenta un maximo para ExpirationSeconds; si rechaza el valor, el
	servidor reintenta con el suyo por defecto (24 h) para no dejar sin link al
	jugador. Un dia largo en el output con "No se pudo generar el link" es la senal
	de que este numero es demasiado alto.
]]
ReferralConfig.Link = {
	PlaceId = 94068794823958,

	Share = {
		ExpirationSeconds = 7 * 24 * 60 * 60,
		PreviewTitle = "¡Vente a Hispana Voice!",
		PreviewDescription = "Entra por mi link y nos vemos dentro.",
	},
}

-- Colores del anillo de progreso del avatar. Mismos que los de las misiones
-- para que las dos barras se lean igual.
ReferralConfig.Colors = {
	InProgress = Color3.fromRGB(0, 170, 255),
	Completed = Color3.fromRGB(255, 165, 62),
	Idle = Color3.fromRGB(0, 88, 129),

	CoinsText = Color3.fromRGB(236, 145, 0),
	GemsText = Color3.fromRGB(15, 185, 197),
}

ReferralConfig.Images = {
	Coins = "rbxassetid://107645265535864",
	Gems = "rbxassetid://101938447947919",
}

--[[
	El dibujo grande de cada tarjeta de la escalera.

	Por defecto se elige segun la moneda, para que lo que se ve y lo que se cobra
	coincidan. En el editor habia tarjetas con gemas y con una llave dando monedas;
	eso era el boceto, no una regla.

	Si quieres que un hito concreto luzca distinto, ponle `Image` en su fila de
	ReferralConfig.Rewards y manda ese.
]]
ReferralConfig.RewardImages = {
	Coins = "rbxassetid://114858420207230", -- monton de monedas
	Gems = "rbxassetid://74113672247864", -- gemas
	Key = "rbxassetid://109793969710074", -- llave de cofre, para hitos gordos
}

-- El candado que tapa el boton de las recompensas que aun no tocan.
ReferralConfig.LockImage = "rbxassetid://77967231798823"

return ReferralConfig
