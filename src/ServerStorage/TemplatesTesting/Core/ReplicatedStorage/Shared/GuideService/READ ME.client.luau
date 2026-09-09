--[[

	HOLA MUCHACHES, SOY LYM, EN ESTE CASO LES EXPLICARE COMO USAR ESTA API PARA EL SISTEMA DE GUIA CON PANTALLAS PARA MOSTRAR A LOS JUGADORES COMO JUGAR O HACER ALGO EN CONCRETO
	
	POR EL MOMENTO MI SISTEMA TIENE SOPORTE PARA CUADROS DE TEXTOS, COPY AND PASTE(TEXTBOX NO EDITABLE) E IMAGENES
	
	Guia como usar el sistema:

	Paso 1: LLAMAR AL MODULO.
	lo que tienen que hacer es ubcar el dentro del ReplicatedStorage
	
	local GuideService = require(game:GetService("ReplicatedStorage"):FindFirstChild("Shared"):FindFirstChild("GuideService")) --//esto va a depender donde está, en este caso esta en la carpeta shareds
	
	Paso 2: Crear/Eliminar una accion y darle su titulo
	el siguiente paso es añadir un Bind, que es para crear su propia seccion para que esté almacenado y listo para usar cuando se llame
	lo que haran será llamar a un metodo "Bind" para crear su propia seccion
	
	GuideService:Bind("Nombre del titulo")--//es importante que cuando creen una seccion traten de no repetir un nombre que ya está en uso
	GuideService:Unbind("Nombre del titulo")--//esta funcion es para eliminar una seccion ya creada, si no esta creada le saldra un mensaje de advertencia diciendo que no existe tal nombre
	
	Paso 3: Crear/Eliminar una pagina
	Como veran el sistema es un sistema de pagina, cuando ustedes le dan al boton de continuar, pasan a la siguiente pagina y en caso de que sea la ultima pagina pues el sistema se saldrá y se guardará en el dataStore
	una vez hayan terminado todo el recorrido, IMPORTANTE que una vez el juego esté al aire los nombres queden fijo
	
	GuideService:AddPage("Nombre de la seccion",1,{
		{
			{
				["type"] = "Text",
				["Options"] = {
				
					Text = "hola a todos.",
					Size = Vector2.new(1,0),
					Font = Enum.Font.SourceSansLight,
					
				},
				
				["type"] = "Copy",
				["Options"] = {
				
					Text = "hola a todos.",
					Size = Vector2.new(1,0),
					Font = Enum.Font.SourceSansLight,
					
				},
				
				["type"] = "Image",
				["Options"] = {
				
					Image = "hola a todos.",
					Size = Vector2.new(1,0),
					
				},
			},
		},
	})
	
	[LEER BIEN]: esto es lo que deben dominar, ya que con esto añadiremos paginas y paginas hasta las que querramos
	
	1er parametro: deberian añadir el nombre que asignaron a su Bind
	2do parametro: aqui deberian de añadir el numero en la que aparezca la pagina, pueden hacerlo tipo, 1,2,3,4,5 y asi sucesivamente, traten de hacerlo
	en orden para que ustedes esten organizados, de todos modos si en caso son unos huevones y colocan como se les canta el orto,
	(6,2,10,3) el sistema se va a encargar de ordenarlos el 2 se vuelve 1, el 3-2, el 6-4 y el 10-5, y asi hasta volver una secuencia del 1-n
	3er parametro: aqui añadirian como por decirlo las propiedades del texto y el tipo de formato que queremos que aparezca
	como explique en el inicio ahora mismo tengo soporte para 3 formatos, Textos, Textos para copiar e imagenes, estos tienen su tipo de PrimaryKey
	
	Text = "Cuadro de texto"
	Copy = "TextBox para copiar enlaces"
	Image = "una imagen"
	
	deberian pasarles una tabla con 2 index ("type", "Options"), el tipo es la key de arribita y el Option es otra tabla donde modificaremos como se verá el formato,
	aqui abajo les enseñaré que pasarle a cada uno y que modificará

	Text/Copy = "Que parametros le paso?"
		- Text: aqui deberia poner el texto que quieran que apareza en la pantalla
		- Size: aqui enviarán un Vector2, te preguntarás por que, es el encargado de manejar el Size.Y, porque el X es el grozor del frame donde se aloja, o sea su parent
			entonces el X se encargará del Scale y el Y del Offset, recomendado solo usar el Scale, porque si usan offset en otro dispositivo con otra resulucion se verá un poco mas grande de cuando lo configuraron
		- Font: esto es super obvio, pasan el Enum.Font.LaFuenteQueQuieran y el texto colocará un tipo de fuente a la seleccionada
		- TextSize: lo mismo que el Vecto2.X, enviaran un numero donde controlarán el Size del Text en Scale, como referencia su Parent, que seria el frame sucesor del TextLabel
	
	Image:
		- Image: aqui colocarán el Image que quieran que aparezca(Ejemplo: "rbxasset://00000")
		- Size: lo mismo que el de los textos
		- SizeImage: lo mismo que TextSize
	
	
	
	
	INICIAR: Aqui les enseñaré como iniciar una pagina
	
	ok esto es muy facil, nada del otro mundo

	GuideService:Start("Nombre de la seccion")
		-nada del otro mundo, con esto ya se inicia automaticamente la guia, ojito que si hay una en proceso le saldrá una alerta diciendo que ya existe uno en proceso y no dejará usar el de ustedes
	
	GuideService:End("Nombre de la seccion")
		-Esto es lo mismo solo que para cerrar una guia que esta en proceso, esto no es recomendable, pero puede ser util cuando por ejemplo hay un frame para trancisiones
		y quieren ocualtar todo lo que esta viendo el jugador, esto forzará el cierre, haganlo tranquilos, si lo fuerzan a medio uso esto limpiará todo y no dejará errores, es seguro
	
	
	Todo los procesos se guardan en el data store, una vez completados el GuideService:Start("Nombre de la seccion", true) deberian colcarle TRUE como segundo parametro
	para que fuerce de nuevo la GUIA, esto asegura que el jugador pueda entrar a un gui presionar un boton y volver a ver la guia, obvio ya no enviará señales al servidor
	porque ya está completado, pero esto sirve mucho por ejemplo cuando el jugador hace algo y se muestra como primera vez a los jugadores que no han hecho la guia
	entonces la proxima vez que vuelvan a hacer la misma accion ya no les saldrá la guia, sino que lo omitirá, muy diferente a ir a un frame donde si presionan un boton pueden volver
	a ver la guia sin ser molesto y por decicion propia.
	
	
	COMO SE CUANDO LA GUIA TERMINA?
	Muy facil pariente, aqui un ejemplo:
	
	local GuideEnded = GuideService:GetEnded("Nombre de la seccion")--//asegurense que su seccion exista
	if GuideEnded then
		local conection = GuideEnded:Connect(function())
			conection:Disconnect()
			prin("esta guia terminó")
		end)
	end
	
	usen siempre if para asegurar que existe la clave que colcaron, esto devolverá un evento donde ustedes al conectarlo y darle la funcion que quieran se ejecutará tras que la guia termine o se cancele

	MUCHAS GRACIAS A LOS QUE SE DIERON TIEMPO DE LEER ESTO <3
]]