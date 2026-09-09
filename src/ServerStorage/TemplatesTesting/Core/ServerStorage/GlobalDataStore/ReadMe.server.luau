if true then return end
--video explicativo: https://youtu.be/WLOcUzn8fbc

local modulo = require(game:GetService("ServerStorage"):WaitForChild("GlobalDataStore"))

--lectura
--creacion
--actualizacion
--eliminar

--[[local success, errorMesasge = modulo:SetData("TestDataStore","prueba1",{hola = true})

if success then
	print("se guardo el dato exitosamente.")
else
	warn(errorMesasge)
end

local success, Data = modulo:GetData("TestDataStore","prueba1")

if success then
	print(Data)
else
	warn(Data)
end

local success, errorMesasge = modulo:SetData("TestGlobalDataStore","prueba2",0)

if success then
	print("se guardo el dato exitosamente.")
else
	warn(errorMesasge)
end

local Data = modulo:GetData("TestGlobalDataStore",false,10,1)

if Data.Success then
	print(Data)
else
	print("error")
end

local success, errorMesasge = modulo:UpdateData("TestGlobalDataStore","prueba3",function(dato)
	if not dato then return 5 end
	return dato + 1
end)

if success then
	print("se actualizo el dato exitosamente.")
else
	warn(errorMesasge)
end

local success, errorMesasge = modulo:DeleteData("TestGlobalDataStore","prueba1")

if success then
	print("se elimino el dato exitosamente.")
else
	warn(errorMesasge)
end]]