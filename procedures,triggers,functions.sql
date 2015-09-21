use hospital
GO

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
select * from precios
select * from institutos
select * from estudios

65. Crear un procedimiento para ingresar estudios programados.
INPUT: nombre del estudio, dni del paciente, matrícula del médico, nombre del instituto, sigla
de la ooss, entero que inserte la cantidad de estudios a realizarse, entero que indique el lapso
en días en que debe repetirse.
Generar todos las tuplas necesarias en la tabla historias.
(Ejemplo: control de presión cada 48hs durante 10 días).
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