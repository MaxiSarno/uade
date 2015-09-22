--------------------------------------------------------------
-------------------    CORRELACIONADAS     -------------------
--------------------------------------------------------------

-- 30. Listar los partidos jugados como local por el Club SAN MARTIN.
-- 31. Proyectar: NroFecha, p.NroZona, Categoria, Visitante, GolesL, GolesV.

select p.NroFecha, p.NroZona, p.Categoria, (select c1.nombre from Clubes c1 where c1.Id_Club = p.Id_ClubL) as Local, p.GolesL, (select c2.nombre from clubes c2 where c2.Id_Club = p.Id_ClubV) as Visitante, p.GolesV
from partidos p 
where exists (
	select 1 from clubes c where c.Nombre = 'SAN MARTIN' and c.Id_Club = p.Id_ClubL)

-- 32. Listar los partidos jugados como local o visitante por el Club Los Andes. (correlacionar)	
-- 33. Proyectar: NroFecha, p.NroZona, Categoria, Local, Visitante, GolesL, GolesV.

select p.NroFecha, p.NroZona, p.Categoria, (select nombre from clubes where Id_Club = p.Id_ClubL) as Local, p.GolesL, (select nombre from clubes where Id_Club = p.Id_ClubV) as visitante, p.GolesV
from partidos p 
where exists (
	select 1 from clubes c where c.nombre = 'LOS ANDES' and (c.Id_Club = p.Id_ClubL or c.Id_Club = p.Id_ClubV))

-- 34. Determinar los jugadores más viejos de cada club ordenados por Club.
-- 35. Proyectar: Jugador, Fecha_Nac, Club.

select j.Nombre, j.Fecha_Nac, (select Nombre from clubes where Id_Club=j.Id_Club) as club 
from jugadores j 
where 3>all
	(select COUNT(*) from jugadores j1 
	where j.Id_Club=j1.Id_Club and j1.Fecha_Nac > j.Fecha_Nac)
order by Id_Club

-- 36. Determinar los clubes con menos de 40 jugadores. (por correlación y agrupamiento).

select * from clubes c where 40 > (
	select COUNT(*) from Jugadores j where j.Id_Club = c.Id_Club)

--------------------------------------------------------------
-------------------    OPERADOR EXISTS     -------------------
--------------------------------------------------------------

--37. Determinar el club donde juegue el jugador FLORES SERGIO.

select * from clubes c where exists (
	select 1 from jugadores j where j.Nombre = 'FLORES, SERGIO' and j.Id_Club = c.Id_Club)

-- 38. Determinar los jugadores de los equipos que no hayan ganado más de 2 partidos.

select * from jugadores j where exists (
	select 1 from general g where g.ganados < 3 and g.Id_Club = j.Id_Club)

-- 39. Proyectar Nombre del jugador y nombre del club ordenados por club y jugador.

select j.Nombre, c.Nombre from jugadores j join clubes c on j.Id_Club = c.Id_Club
order by c.Nombre, j.Nombre

-- 40. Determinar los partidos que se perdio como local y que haya jugado el jugador FLORES, SERGIO.
-- 41. Proyectar: NroFecha, p.NroZona, Categoria, Local, Visitante, GolesL, GolesV

select p.NroFecha, p.NroZona, p.Categoria, (select nombre from clubes where Id_Club = p.Id_ClubL) as Local, (select nombre from clubes where Id_Club = p.Id_ClubV) as Visitante, p.GolesL, p.GolesV from partidos p 
where p.GolesL < p.GolesV and exists (
	select 1 from jugadores j where j.nombre = 'FLORES, SERGIO' and (j.Id_Club = p.Id_ClubL or j.Id_Club = p.Id_ClubV))

--------------------------------------------------------------
-------------------     OPERADOR  ANY      -------------------
--------------------------------------------------------------

-- 42. Listar los jugadores que no se encuentren entre los mas viejos de cada club.(no utilizar la función min()).
-- 43. Proyectar nombre del jugador, fecha de nacimiento con formato: dd mmm aaaa y nombre del club.

select * from jugadores j 

-- 44. Listar los jugadores de la categoría 84 cuyo club haya marcado mas de 10 goles de visitante en algún partido.
-- 45. Proyectar Nombre del Jugador, Categoría y Nombre del Club.

select j.Nombre, J.Categoria, (select nombre from clubes where Id_Club=j.Id_Club) as Club
from jugadores j where j.Categoria = 84 and 10 < any (select p.GolesV from Partidos p where p.Id_ClubV=j.Id_Club)

46. Listar los clubes que ganaron 2 o mas partidos por dos goles de diferencia 

select * from clubes c where 2<=any (
	select count(*) from (
		select pV.Id_ClubV as Id_Club from partidos pV where (pV.GolesL+2) = pV.GolesV
		union all
		select pL.Id_ClubL as Id_Club from partidos pL where pL.GolesL = (2+pL.GolesV) ) dopartis
	where dopartis.Id_Club = c.Id_Club
	group by dopartis.Id_Club)

select * from clubes c where c.Id_Club=any (
	select Id_Club from (
		select pV.Id_ClubV as Id_Club from partidos pV where (pV.GolesL+2) = pV.GolesV
		union all
		select pL.Id_ClubL as Id_Club from partidos pL where pL.GolesL = (2+pL.GolesV) ) dopartis
	group by dopartis.Id_Club
	having count(*) >= 2)
	
--------------------------------------------------------------
-------------------     OPERADOR  ALL      -------------------
--------------------------------------------------------------

47. Listar los jugadores que se encuentren entre los más jóvenes de cada club. (no utilizar max())

select * from jugadores j where 3 > all
	(select COUNT(*)
	from Jugadores j1
	where j1.Fecha_Nac < j.Fecha_Nac
		and j1.Id_Club = j.Id_Club)
order by j.Id_Club

48. Listar los Clubes de la categoría 85 que no hayan marcado goles en ningún partido jugando de visitante en las primeras 6 fechas.

Select * from clubes c where 1> all
	(select p.GolesV from partidos p 
	where p.Categoria=85
		and p.NroFecha <= 6
		and p.Id_ClubV = c.Id_Club)

49. Listar los jugadores de la categoría 84 que hayan marcado goles en todos los partidos de las primeras 8 fechas.
???????????????????????????
select * from partidos p
where p.NroFecha < 9

50. Listar los jugadores y el nombre del club con menor diferencia de goles.
select * from general g
where 2> all
	(select COUNT(*) from general g1
	where g1.Diferencia < g.Diferencia)
	
--------------------------------------------------------------
-------------------   CUALQUIER OPERADOR   -------------------
--------------------------------------------------------------

CUALQUIER OPERADOR
51. Determinar el Club y la cantidad de jugadores de los clubes que ganaron más partidos que los que perdieron.

select nombre, (select COUNT(*) from jugadores where Id_Club=g.Id_Club) as 'cant jugadores' from General g
where g.Ganados>g.Perdidos

52. Listar los 5 números de documento más altos de los jugadores de cada categoría.

select * from jugadores j where 5 > all
	(select count(*) from jugadores j1
	where j1.Categoria = j.Categoria
		and j1.Nrodoc > j.Nrodoc)

53. Listar los 3 números de documento más bajos de los jugadores de cada club.

select * from jugadores j where 3 > all
	(select COUNT(*) from jugadores j1 
	where j1.Id_Club = j.Id_Club
		and j1.Nrodoc > j.Nrodoc)
order by Id_Club, Nrodoc


54. Listar el 5a y 6a número de documento más alto de los jugadores de cada club.

select * from jugadores j where 
	(select COUNT(*) from Jugadores j1
	where j1.Id_Club = j.Id_Club
		and j1.Nrodoc>j.Nrodoc)
	between 5 and 6

55. Listar equipo y zona de la categoría 85 que hayan empatado entre la 5o y 7o fecha.

select * from clubes c where c.Id_Club in 
	(select p1.Id_ClubL from Partidos p1
	where p1.NroFecha between 5 and 7
	and p1.GolesL-p1.GolesV=0
	and p1.Categoria=85
	union all
	select p1.Id_ClubV from Partidos p1
	where p1.NroFecha between 5 and 7
	and p1.GolesL-p1.GolesV=0
	and p1.Categoria=85)

56. Listar los equipos que ganaron por 10 goles de diferencia en la zona número 2.

select p.Id_ClubL from partidos p where p.NroZona=2 and p.GolesL = p.GolesV+10
union all
select p2.Id_ClubV from partidos p2 where p2.NroZona=2 and p2.GolesL+10 = p2.GolesV

57. Listar los equipos de la zona 1 que marcaron goles en las 5 primeras fechas jugando de visitante.

select * from clubes c 
where 0 < all
	(select p.golesV from partidos p where p.Id_ClubV = c.Id_Club and p.NroFecha <= 5)
	and c.Nrozona=1

58. Listar los equipos que no marcaron goles en las 5 primeras fechas.
???????????????????????????????????????????????
select * from clubes c 
where 0 = all
	(select p.golesV from partidos p where p.Id_ClubV = c.Id_Club and p.NroZona=1 and p.NroFecha <= 5)
and 0=all
	(select p.golesL from partidos p where p.Id_ClubL = c.Id_Club and p.NroZona=1 and p.NroFecha <= 5)

59. Listar los equipos de la categoría 85 que no hayan ganado de local en la primera fecha.

select * from clubes c where c.Id_Club in 
	(select p.Id_ClubL from partidos p
	where p.NroFecha = 1
		and p.Categoria = 85
		and p.GolesL <= p.GolesV)

60. Cantidad de Jugadores por categoría de los equipos que no participaron en la primera fecha del campeonato.

select (select nombre from clubes c where c.Id_Club=j.Id_Club) as club, j.Categoria, COUNT(*) as cant from jugadores j where j.Id_Club in 
	(select c.Id_Club from clubes c where c.Id_Club not in 
		(select p.Id_ClubL as id from partidos p where p.NroFecha=1
		union all
		select p.Id_ClubV as id from Partidos p where p.NroFecha=1))
group by j.Id_Club, j.Categoria

61. Listar los equipos que no posean partidos empatados.

select * from clubes c where c.Id_Club not in 
	(select p.Id_ClubL from partidos p
	where p.GolesL = p.GolesV
	union all
	select p.Id_ClubV from partidos p
	where p.GolesL = p.GolesV)

62. Listar todos los equipos que finalizaron ganando 2 a 0.

select * from clubes c where c.Id_Club in 
	(select p.Id_ClubL from partidos p
	where p.GolesL+2 = p.GolesV
	union all
	select p.Id_ClubV from partidos p
	where p.GolesL = 2+p.GolesV)

63. Identificar a los equipos que participaron en el partido que hubo mayor diferencia de goles.

??????????????????????????????????

--------------------------------------------------------------
-------------------    STORE PROCEDURES    -------------------
--------------------------------------------------------------

--64. Crear un procedimiento para ingresar el precio de un estudio.
--INPUT: nombre del estudio, nombre del instituto y precio.
--Si ya existe la tupla en Precios debe actualizarla.
--Si no existe debe crearla.
--Si no existen el estudio o el instituto debe crearlos.

create procedure nro64
	@nomEstudio varchar(30),
	@nomInstituto varchar(30),
	@precio int
AS
	declare @idEstudio int, @idInstituto int
	select @idEstudio = idestudio from estudios where estudio = @nomEstudio
	if (@idEstudio is null)
	begin
		select @idEstudio = isnull(max(idestudio),0)+1 from estudios
		insert into estudios values (@idEstudio, @nomEstudio, 'verdadero')
	end

	select @idInstituto= idinstituto from institutos where instituto = @nomInstituto
	if (@idInstituto is null)
	begin
		select @idInstituto = isnull(max(idinstituto),0)+1 from institutos
		insert into institutos values (@idInstituto, @nomInstituto, 'verdadero')
	end

	if(exists(select * from precios where @idEstudio = idestudio and @idInstituto= idinstituto))
		update precios set precio = precio where @idEstudio = idestudio and @idInstituto= idinstituto
	else
		insert into precios values (@idEstudio, @idInstituto, @precio)

RETURN

exec nro64 @nomEstudio='fondo de ojos', @nomInstituto='trinidad', @precio=1000

--65. Crear un procedimiento para ingresar estudios programados.
--INPUT: nombre del estudio, dni del paciente, matrícula del médico, nombre del instituto, sigla
--de la ooss, entero que inserte la cantidad de estudios a realizarse, entero que indique el lapso
--en días en que debe repetirse.
--Generar todos las tuplas necesarias en la tabla historias.
--(Ejemplo: control de presión cada 48hs durante 10 días).

create procedure nro65 
	@nomEstudio varchar(30),
	@dni varchar(8),
	@matrícula int,
	@nomInstituto varchar(30),
	@siglaOS varchar(30),
	@cantEstudios int,
	@lapsoARepetirse int
AS
	declare @idEstudio int, @idInstituto int, @fecha datetime
	select @idEstudio=idestudio from estudios where @nomEstudio=estudio
	select @idInstituto=idinstituto from institutos where @nomInstituto=instituto

	SET @fecha = GETDATE()

	while @cantEstudios>0
	begin
		set @cantEstudios = @cantEstudios-1
		set @fecha = DATEADD(dd,@lapsoARepetirse,@fecha)
		insert into historias values (@dni, @idEstudio, @idInstituto, @fecha, @matrícula, @siglaOS, 'f', '')
	end
RETURN

select * from historias
select * from estudios
select * from institutos
select * from medicos
select * from obrassociales

exec nro65 'ESTUDIO_01', '00000001', 1, 'INSTITUTO_01', 'OSDE', 3, 2

66. Crear un procedimiento para ingresar datos del afiliado.
INPUT: dni del paciente, sigla de la ooss, nro del plan, nro de afiliado.
Si ya existe la tupla en Afiliados debe actualizar el nro de plan y el nro de afiliado.
Si no existe debe crearla.
67. Crear un procedimiento para que proyecte los estudios realizados en un determinado mes.
INPUT: mes y año.
Proyectar los datos del afiliado y los de los estudios realizados.
68. Crear un procedimiento que proyecte los pacientes según un rango de edad.
INPUT: edad mínima y edad máxima.
Proyectar los datos del paciente.
69. Crear un procedimiento que proyecte los datos de los médicos para una determinada
especialidad.
INPUT: nombre de la especialidad y sexo (default null).
Proyectar los datos de los médicos activos que cumplan con la condición. Si no se especifica
sexo, listar ambos.
70. Crear un procedimiento que proyecte los estudios que están cubiertos por una determinada
obra social.
INPUT: nombre de la ooss, nombre del plan ( default null ).
Proyectar los estudios y la cobertura que poseen (estudio y porcentaje cubierto.
Si no se ingresa plan, se deben listar todos los planes de la obra social.
71. Crear un procedimiento que proyecte cantidad de estudios realizados agrupados por ooss,
nombre del plan y matricula del medico.
INPUT: nombre de la ooss, nombre del plan, matrícula del mádico.
(todos deben admitir valores nulos por defecto )
Proyectar la cantidad de estudios realizados.
Si no se indica alguno de los parámetros se deben discriminar todas las ocurrencias.
72. Crear un procedimiento que proyecte dni, fecha de nacimiento, nombre y apellido de los
pacientes que correspondan a los n (valor solicitado) pacientes más viejos cuyo apellido cumpla
con determinado patrón de caracteres.
INPUT: cantidad (valor n), patrón caracteres (default null).
Proyectar los pacientes que cumplan con la condición.
(Ejemplo: los 10 pacientes más viejos cuyo apellido finalice con ‘ez’ o los 8 que comiencen con
‘A’
73. Crear un procedimiento que devuelva el precio total a liquidar a un determinado instituto.
INPUT: nombre del instituto, periodo a liquidar.
OUTPUT: precio neto.
Devuelve el neto a liquidar al instituto para ese período en una variable.
74. Crear un procedimiento que devuelva el precio total a facturar y la cantidad de estudios
intervinientes a una determinada obra social.
INPUT: nombre de la obra social, periodo a liquidar.
OUTPUT: precio neto, cantidad de estudios.
Devuelve en dos variables el neto a facturar a la obra social o prepaga y la cantidad de estudios
que abarca para un determinado período.
75. Crear un procedimiento que devuelva el monto a abonar de un paciente moroso.
INPUT: dni del paciente, estudio realizado, fecha de realización, punitorio (mensual).
OUTPUT: precio neto.
Obtener punitorio diario y precio a abonar.
Devuelve precio + punitorio en una variable.
76. Crear un procedimiento que devuelva el precio mínimo y el precio máximo que debe abonar a
una obra social.
INPUT: sigla de la obra social o prepaga
OUTPUT: mínimo, máximo.
Devolver en dos variables separadas el monto mínimo y máximo a ser cobrados por la obra
social o prepaga.
77. Crear un procedimiento que devuelva la cantidad posible de juntas médicas que puedan
crearse combinando los médicos existentes.
INPUT / OUTPUT: entero.
Ingresar la cantidad de combinaciones posibles de juntas entre médicos ( 2 a 6 ) que se
pueden generar con los médicos activos de la Base de Datos.
Retorna la Combinatoria (m médicos tomados de a n ) = m! / n! (m-n)! en una variable.

--78. Crear un procedimiento que devuelva la cantidad de pacientes y médicos que efectuaron
--estudios en un determinado período.
--INPUT / OUTPUT: dos enteros.
--Ingresar período a consultar (mes y año )
--Retornar cantidad de pacientes que se realizaron uno o más estudios y cantidad de médicos
--solicitantes de los mismos, en dos variables.

create procedure nro78
	@mes int,
	@anio int,
	@cantPacientes int output,
	@cantMedicos int output
AS
	select @cantPacientes=count(distinct dni) from historias where @mes=DATEPART(mm,fecha) and @anio=DATEPART(yy,fecha)
	select @cantMedicos=count(distinct matricula) from historias where @mes=DATEPART(mm,fecha) and @anio=DATEPART(yy,fecha)
return

declare @a int, @b int
exec nro78 @mes=9, @anio=2015, @cantPacientes=@a out, @cantMedicos=@b out
select @a , @b 

--------------------------------------------------------------
-------------------        TRIGGERS        -------------------
--------------------------------------------------------------

--79. Crear un Trigger:
--Que indique con un mensaje que no se permite eliminar las historias de los pacientes.

create trigger nro79 for historias
instead of delete
as
	print 'no se puede borrar, pa'
	rollback transaction
go

--80. Crear un Trigger:
--Que modifique la condición de médico activo sin eliminarlo.
--El trigger no debe permitir eliminar a un médico, se lo debe registrar como inactivo.

create trigger nro80 on medicos
instead of delete
as
	update medicos set activo='falso' where matricula=
		(select matricula from deleted)
go

select * from medicos
delete from medicos where matricula = 9

--81. Crear los Triggers:
--Que determinen el número correspondiente al id de especialidad y al id de estudio cada vez que
--se registre una nueva especialidad o un nuevo estudio en la Base de Datos. Los id no deben
--ingresarse sino calcularse como el número siguiente correlativo a los ya existentes para cada
--caso.

create trigger nro81a on especialidades
instead of insert
as
	declare @id int, @nombre varchar(30)
	select @id=max(idespecialidad)+1 from especialidades
	insert into especialidades values (@id,(select especialidad from inserted))
go

create trigger nro81b on estudios
instead of insert
as
	declare @id int, @nombre varchar(30)
	select @id=max(idestudio)+1 from estudios
	select @nombre = estudio from inserted
	insert into estudios values (@id,@nombre,'verdadero')
go

82. Crear un Trigger:
Que determine el número de plan correspondiente al plan de la obra social cada vez que se
registre uno nuevo en la Base de Datos. El número de plan se calcula en forma correlativa a los
ya existentes para esa obra social, comenzando con 1 (uno) el primer plan que se ingrese a
cada obra social o prepaga.

--83. Crear un Trigger:
--Que muestre el valor anterior y el nuevo valor de cada columna que se actualizó en la tabla
--pacientes.

create trigger nro83 on pacientes
for update
as
	declare @id varchar(10), @viejo varchar(20), @nuevo varchar(20)
	select @id=dni from inserted

	if UPDATE(nombre)
	begin
		select @viejo=nombre from deleted
		select @nuevo=nombre from inserted
		print 'titulo viejo:'+@viejo+' nuevo:'+@nuevo
	end
go

--84. Crear un Trigger:
--Que controle que un mismo estudio tenga hasta un máximo e 6 institutos donde pueda
--realizarse.

create trigger nro84 on precios
after insert, update
as
	declare @cant int
	select @cant=count(idinstituto) from precios where idestudio=(select idestudio from inserted)
	if @cant>6
	begin
		rollback transaction
		print 'hasta 6 se puede, no mas'
	end
go

85. Crear un Trigger:
Que controle que un médico no indique un estudio a un paciente que no sea afín con la
especialidad del médico.
86. Crear un Trigger:
Que controle que todas las historias que correspondan al estudio que hace referencia en ese
instituto, se encuentran pagadas para poder permitir que se modifique el precio del estudio.

--------------------------------------------------------------
-------------------        FUNCIONES       -------------------
--------------------------------------------------------------

--87. Definir una función que devuelva la edad de un paciente.
--INPUT: fecha de nacimiento.
--OUTPUT: edad expresada en años cumplidos.

create function nro87 (@fechaNac datetime)
returns int
as
begin
	declare @dif int
	set @dif=datediff(yy, @fechaNac, getdate())
	return @dif
end
go	

select dbo.nro87('1987-09-01')

--88. Definir las siguientes funciones para obtener:
--INPUT: nombre del estudio.
--OUTPUT: mayor precio del estudio.
--menor precio del estudio.
--precio promedio del estudio.

create function nro88 (@nomEstudio varchar(20))
returns @tabla table (nomEstudio varchar(20), min int, max int, avg int)
as
begin
	declare @min int, @max int, @avg int
	select @min=min(precio) from precios
	select @max=max(precio) from precios
	select @avg=avg(precio) from precios
	insert @tabla
	select @nomEstudio, @min, @max, @avg
	return
end
go

select nomEstudio, min, max, avg from nro88('fondo de ojos')

--89. Definir una función que devuelva los n institutos más utilizados por especialidad.
--INPUT: nombre de la especialidad, cantidad máxima de institutos.
--OUTPUT: Tabla de institutos (n primeros ).
select * from historias where idestudio

select idestudio from precios where ides
select estu.idestudio
from especialidades espe
	join estudios_especialidades ee on espe.idespecialidad = ee.idespecialidad
	join estudios estu on estu.idestudio = ee.idestudio
where especialidad='ESPECIALIDAD_01'

select * from especialidades

create function nro89 (@nomEspecialidad varchar(20), @cantMaxInstitutos int)
returns @institut table (idinstituto smallint, instituto char(10), activo char(10))
as
begin
	select @idEst=estu.idestudio
	from especialidades espe
		join estudios_especialidades ee on espe.idespecialidad = ee.idespecialidad
		join estudios estu on estu.idestudio = ee.idestudio
	where especialidad='ESPECIALIDAD_01'

	insert @institut
	select * from institutos where  idinstituto in
		(select h.idinstituto from historias h where 2 > all
			(select COUNT(*) from historias h1
			where h.idestudio=1 ))
	return
end
go
???????????????????????????

select * from nro89('',1)

90. Definir una función que devuelva los estudios que no se realizaron en los últimos días.
INPUT: cantidad de días.
OUTPUT: Tabla de estudios.



91. Definir una función que devuelva los estudios y la cantidad de veces que se repitieron para
un mismo paciente a partir de una cantidad mínima que se especifique y dentro de un
determinado período de tiempo.
INPUT: cantidad mínima, fecha desde, fecha hasta.
OUTPUT: Tabla que proyecte el paciente, el estudio y la cantidad.
92. Definir una función que devuelva los médicos que ordenaron repetir un mismo estudio a un
mismo paciente en los últimos días.
INPUT: cantidad de días.
OUTPUT: Tabla que proyecte el estudio repetido, nombre y fechas de realización, identificación
del paciente y del médico.
93. Definir una función que devuelva una cadena de caracteres en letras minúsculas con la letra
inicial de cada palabra en mayúscula.
INPUT: string inicial.
OUTPUT: string convertido.
94. Definir una función que devuelva el mayor entre un mínimo de 2 y un máximo de 4
números reales.
INPUT: de 2 a 4 valores numéricos.
OUTPUT: 1 valor numérico.
95. Definir una función que devuelva las obras sociales que cubren un determinado estudio en
todos los planes que tiene y que se realizan en algún instituto registrado en la base.
INPUT: nombre del estudio.
OUTPUT: Tabla que proyecta la obra social y la categoría.
96. Definir una función que devuelva la cantidad de estudios y la cantidad de institutos para una
determinada obra social.
INPUT: sigla de la obra social.
OUTPUT: Tabla que proyecte obra social, estudio, cantidad del estudio, instituto, cantidad del
instituto, (opcionalmente nro. de orden ).
97. Definir una función que proyecte un descuento adicional a los afiliados de una obra social,
del 5% a los estudios de cardiología y del 7% a los de gastroenterología, para aquellos que no
tienen cubierto el 100% del estudio.
INPUT: sigla de la obra social.
OUTPUT: Tabla que proyecte los datos del paciente, del estudio y el monto neto del 3
5541descuento.