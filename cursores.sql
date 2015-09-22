
--CURSORES

/*1.	Definir un Cursor:
Que liste la ficha de los pacientes de los últimos seis meses conforme al siguiente 
formato de salida:

Datos del paciente.
		Identificación del médico.
			Detalle de los estudios realizados.*/


declare @dni varchar(10), @nombre varchar(50), @apellido varchar(50), @sexo varchar(1), @nacimiento datetime, 
			@matricula smallint, @nombreMedico varchar(50), @apellidoMedico varchar(50), @sexoMedico varchar(1),
			@instituto varchar(50), @estudio varchar(50), @fecha datetime

declare	cursorcito cursor forward_only read_only 
for select p.dni, p.nombre, p.apellido, p.sexo, p.nacimiento, 
			m.matricula, m.nombre, m.apellido, m.sexo,
			i.instituto, e.estudio, h.fecha
	from  (((historias h inner join pacientes p on p.dni = h.dni) 
			inner join medicos m on m.matricula = h.matricula )
				inner join institutos i on i.idinstituto = h.idinstituto)
					inner join estudios e on e.idestudio = h.idestudio
	where h.fecha between (getdate()-180) and getdate()

open cursorcito

fetch next from cursorcito into @dni, @nombre, @apellido, @sexo, @nacimiento, 
			@matricula, @nombreMedico, @apellidoMedico, @sexoMedico, @instituto, @estudio, @fecha
else
    PRINT space(5)+'Estudios realizados en los ultimos 6 meses: '

if @@fetch_status <> 0
	PRINT space(20)+'No hay estudios'

while @@fetch_status = 0
begin
	PRINT @dni+' '+ @nombre+' '+ @apellido+' '+ @sexo+' '+ convert(char(11), @nacimiento)+' '+ 
			convert(char(3),@matricula)+' '+ @nombreMedico +' '+ @apellidoMedico+' '+ 
			@sexoMedico+' '+ @instituto+' '+ @estudio+' '+ convert(char(11), @fecha)
	fetch next from cursorcito into @dni, @nombre, @apellido, @sexo, @nacimiento, 
			@matricula, @nombreMedico, @apellidoMedico, @sexoMedico, @instituto, @estudio, @fecha	
end
close cursorcito
deallocate cursorcito
GO

/*2.	Definir un Cursor:
Que liste el detalle de los planes que cubren un determinado estudio identificando el porcentaje cubierto y
la obra social, según formato:

Estudio.
		Obra social.
			Plan y Cobertura (ordenado en forma decreciente). */

declare @estudio varchar(50), @obrasocial char(50), @plan varchar(50), @cobertura float

declare cursorcito_planes cursor forward_only read_only
for select e.estudio, ooss.nombre, p.nombre, c.cobertura
	from (((estudios e inner join coberturas c on e.idestudio = c.idestudio)
		inner join planes p on c.nroplan = p.nroplan)
		inner join obrassociales ooss on p.sigla = ooss.sigla)
	where (c.cobertura > 0)
	order by c.cobertura desc

open cursorcito_planes

fetch next from cursorcito_planes into @estudio, @obrasocial, @plan, @cobertura

if (@@fetch_status <> 0)
	PRINT 'No hay estudios cubiertos'
else
    PRINT 'Los estudios cubiertos son:'

while @@fetch_status = 0
begin
	PRINT @estudio + ' '
	PRINT space(10) + @obrasocial 
	PRINT space(20) + @plan+ ' '+ convert(char(4), @cobertura * 100) + '%'
	fetch next from cursorcito_planes into @estudio, @obrasocial, @plan, @cobertura
end
close cursorcito_planes
deallocate cursorcito_planes
GO

/*3.	Definir un Cursor:
Que liste la cantidad estudios realizados mostrando parciales por paciente y por instituto, 
conforme al siguiente detalle:

Datos del paciente	
		Instituto 	Cantidad de estudios.
			Total de estudios realizados por el paciente.
	Total de estudios realizados (todos los pacientes).*/


declare @dni varchar(10), @nombre char(50), @apellido char(50), @sexo char(1), @nacimiento datetime,
		@instituto varchar(50), @cantPorInstituto int, @cantPorPaciente int, @total int

select @total = 0
declare cursorcito_paciente cursor forward_only read_only
for 
	select p.dni, p.nombre, p.apellido, p.sexo, p.nacimiento
	from pacientes p

open cursorcito_estudios

fetch next from cursorcito_paciente into @dni, @nombre, @apellido, @sexo, @nacimiento
if (@@fetch_status <> 0)
	PRINT 'No hay pacientes'
else
    PRINT 'Los pacientes son:'

while @@fetch_status = 0
begin
	select @cantPorPaciente = 0
	PRINT @dni+ ' ' +rtrim(@nombre)+ ' ' +rtrim(@apellido)+ ' ' +@sexo+ ' ' +convert(char(10),@nacimiento)
	
	declare subcursorcito_estudios cursor forward_only read_only
	for 
		select i.instituto, count(h.dni) as cantPorInstituto
		from historias h inner join institutos i on h.idinstituto = i.idinstituto
		where h.dni like @dni
		group by i.instituto
	
	open subcursorcito_estudios

	fetch next from subcursorcito_estudios into @instituto, @cantPorInstituto
	if (@@fetch_status <> 0)
		PRINT 'No hay estudios'
	else
		PRINT space(10) + 'Cantidad de estudios por Institutos:'
	
	while @@fetch_status = 0
	begin
		select @cantPorPaciente = @cantPorPaciente + @cantPorInstituto
		PRINT space(10) + @instituto+ ' ' +convert(char(10),@cantPorInstituto)
		fetch next from subcursorcito_estudios into @instituto, @cantPorInstituto
	end
	select @total = @total+ @cantPorPaciente
	close subcursorcito_estudios
	deallocate subcursorcito_estudios
	PRINT space(20) +'Cantidad de estudios para este paciente: '+convert(char(10), @cantPorPaciente )
	fetch next from cursorcito_paciente into @dni, @nombre, @apellido, @sexo, @nacimiento
end
PRINT space(30) +'Cantidad de estudios total: '+ convert(char(10),@total )
close cursorcito_paciente
deallocate cursorcito_paciente
GO

/*4. Definir un Cursor:
Que liste la cantidad estudios solicitados mostrando parciales por estudio y por médico, 
y detalle de los estudios solicitados conforme al siguiente formato:

Datos del médico	
	Nombre del estudio
			Fecha 	Paciente
			Cantidad del estudio 
		Cantidad de estudios del médico*/


declare @matricula smallint, @nombre char(50), @apellido char(50), @sexo char(1),
		@estudio varchar(50), @fecha datetime, @dni varchar(10),@cantPorEstudio int, @cantPorMedico int

declare cursorcito_estudios2 cursor forward_only read_only
for select m.matricula, m.nombre, m.apellido, m.sexo
from medicos m

open cursorcito_estudios2

fetch next from cursorcito_estudios2 into @matricula, @nombre, @apellido, @sexo
if (@@fetch_status <> 0)
	PRINT 'No hay estudios'
else
    PRINT 'Los estudios son:'

while @@fetch_status = 0
begin
	select @cantPorMedico = 0
	PRINT convert(char(5),@matricula)+ ' ' +rtrim(@nombre)+ ' ' +rtrim(@apellido)+ ' ' +@sexo
	
	declare subcursorcito_estudios2 cursor forward_only read_only
	for select e.estudio 
	from estudios e inner join historias h on e.idestudio = h.idestudio
	where h.matricula = @matricula
	
	open subcursorcito_estudios2

	fetch next from subcursorcito_estudios2 into @estudio
	if (@@fetch_status <> 0)
		PRINT 'No hay estudios'
	else
		PRINT space(10) + 'Estudio:'
	
	while @@fetch_status = 0
	begin
		select @cantPorEstudio = 0
		PRINT space(10) + @estudio
		fetch next from subcursorcito_estudios2 into @estudio
	
		declare sub_subcursorcito_estudios2 cursor forward_only read_only
		for select h.fecha, h.dni
		from historias h inner join estudios e on h.idestudio = e.idestudio 
		where e.estudio like @estudio
	
		open sub_subcursorcito_estudios2
		fetch next from sub_subcursorcito_estudios2 into @fecha, @dni
		if (@@fetch_status <> 0)
			PRINT 'No hay pacientes'
		else
			PRINT space(10) + ''
		
		while @@fetch_status = 0
		begin
			select @cantPorEstudio = @cantPorEstudio +1
			PRINT space(10) + convert(char(10),@fecha) +' '+convert(char(10),@dni)
			fetch next from sub_subcursorcito_estudios2 into @fecha, @dni
		end
		select @cantPorMedico = @cantPorMedico + @cantPorEstudio
		PRINT space(20) +'Cantidad de estudios: '+convert(char(10), @cantPorEstudio)
		close sub_subcursorcito_estudios2
		deallocate sub_subcursorcito_estudios2
	end
	close subcursorcito_estudios2
	deallocate subcursorcito_estudios2
	fetch next from cursorcito_estudios2 into @matricula, @nombre, @apellido, @sexo
	PRINT space(30) +'Cantidad de estudios para el medico: '+convert(char(10), @cantPorMedico)
end
close cursorcito_estudios2
deallocate cursorcito_estudios2
GO

/*5.	Crear una Stored Procedure que defina un Cursor:
Que liste el resumen mensual de los importes a cargo de una obra social.
INPUT: nombre de la obra social, mes y año a liquidar.

Obra social	
	Nombre del Instituto
			Detalle del estudio
			Subtotal del Instituto  
		Total de la obra social*/

ALTER PROCEDURE resumenMensual  
@os char(50),
@mes varchar(2),
@ano varchar(4)
AS 
	declare @instituto varchar(50), @estudio varchar (50), @idestudio smallint, @precio float,  
			@subtotal float, @total float
	select @total = 0
	declare cursorcito_mensual cursor 
	for select distinct i.instituto 
	from (historias h inner join institutos i on i.idinstituto = h.idinstituto) 
			inner join obrassociales os on os.sigla = h.sigla
	where os.nombre like @os and datepart(mm, h.fecha)=@mes and datepart(yy, h.fecha)=@ano
	
	open cursorcito_mensual
	
	PRINT @os
	fetch next from cursorcito_mensual into @instituto
	if (@@fetch_status <> 0)
		PRINT 'No hay institutos'
	else	
		while @@fetch_status = 0
		begin
			PRINT @instituto
			select @subtotal = 0
			declare subcursorcito_mensual cursor
			for select e.idestudio, e.estudio, p.precio 
			from ((precios p inner join historias h on h.idestudio = p.idestudio and h.idinstituto = p.idinstituto)
					inner join institutos i on i.idinstituto = p.idinstituto)
						inner join estudios e on e.idestudio = p.idestudio
			where i.instituto like @instituto and datepart(mm, h.fecha)=@mes and datepart(yy, h.fecha)=@ano
			
			open subcursorcito_mensual 
			
			fetch next from subcursorcito_mensual into @idestudio, @estudio, @precio
			
			if (@@fetch_status <> 0)
				PRINT 'No hay estudios'
			else 
				while @@fetch_status = 0
				begin 
					select @subtotal = @subtotal + @precio
					PRINT space(10) + convert(char(5),@idestudio) +' '+@estudio
					fetch next from subcursorcito_mensual into @idestudio, @estudio, @precio
				end
				PRINT space(10)+'Subtotal: '+convert(char(10),@subtotal)
				close subcursorcito_mensual
				deallocate subcursorcito_mensual
			select @total=@total+@subtotal
			fetch next from cursorcito_mensual into @instituto
		end
		close cursorcito_mensual
		deallocate cursorcito_mensual
		PRINT 'Total: '+convert(char(10),@total	)
GO


resumenMensual 'Instituto y obras', '05', '2009'


/*6.	Definir un Cursor:
Que devuelva una tabla de referencias cruzadas que exprese la cantidad de 
estudios realizados por los pacientes de una determinada  obra social discriminando por plan. 
INPUT: obra social.

Obra Social: nombre de la obra social

			Plan  A		Plan  B 	Plan  C 
Estudio 1		n			n			-
Estudio 2		n			- 			n*/

declare @sigla char(8)
select @sigla='OSDE'

declare @estudio varchar(50), @plan varchar(50), @planEstudio varchar(50), @cont int,
		@encabezado varchar(500)
select @encabezado = ' ' 
declare cursorcito_tabla cursor scroll
for select distinct p.nombre 
from ((historias h inner join estudios e on h.idestudio = e.idestudio)
		inner join afiliados a on h.dni = a.dni and a.sigla = h.sigla)
			inner join planes p on p.nroplan = a.nroplan
--where p.sigla like 'OSDE'
order by p.nombre

open cursorcito_tabla

fetch next from cursorcito_tabla into @plan
if (@@fetch_status <> 0)
	PRINT 'No hay estudios'
else
    while @@fetch_status = 0
	begin
		select @encabezado = @encabezado +'    '+ @plan
		fetch next from cursorcito_tabla into @plan
	end
	PRINT @encabezado

close cursorcito_tabla
deallocate cursorcito_tabla

declare cursorcito_estudio cursor 
for select e.idestudio, p.nombre 
from (estudios e inner join coberturas c on c.idestudio = e.idestudio )
		inner join planes p on p.sigla = c.sigla and p.nroplan = c.nroplan
open cursorcito_estudio
fetch next from cursorcito_estudio into @estudio, @planEstudio
if (@@fetch_status <> 0)
	PRINT 'No hay estudios'
else 
	begin 
	while @@fetch_status = 0
	begin
		--PRINT @estudio
		select @cont = 0
		--fetch prior from cursorcito_tabla
		declare cursorcito_tabla2 cursor scroll
		for select distinct p.nombre 
		from ((historias h inner join estudios e on h.idestudio = e.idestudio)
				inner join afiliados a on h.dni = a.dni and a.sigla = h.sigla)
					inner join planes p on p.nroplan = a.nroplan
		--where p.sigla like 'OSDE'
		order by p.nombre

		open cursorcito_tabla2	

		fetch next from cursorcito_tabla2 into @plan
		while @@fetch_status = 0
		begin
			if (@plan = @planEstudio)
				select @estudio = @estudio + space(10)+space(10*@cont)+'n'
			fetch next from cursorcito_tabla2 into @plan
			select @cont = @cont +1
		end
		PRINT @estudio
		fetch next from cursorcito_estudio into @estudio, @planEstudio
		close cursorcito_tabla2
		deallocate cursorcito_tabla2
	end
	end

close cursorcito_estudio
deallocate cursorcito_estudio


/*7.	Crear una Stored Procedure que defina un Cursor:
Que devuelva una tabla de referencias cruzadas que exprese la cantidad de estudios realizados por
institutos en un determinado período.
INPUT: fecha desde, fecha hasta.

Período: del nn/nn/nn al nn/nn/nn

Estudio I	Estudio II 	Estudio III
Inst. A		n		n		-
Inst. B		n		- 		n*/

/*8.	Crear una Stored Procedure que defina un Cursor:
Que devuelva una tabla de referencias cruzadas que represente el importe mensual 
abonado a cada instituto en los últimos n meses.
INPUT: entero que representa los n meses anterioes.

Mes año	Mes año	Mes año	Mes año	Total Inst.
Inst. A		-		-		$		$		$
Inst. B		$		$ 		-		$		$
Total			$		$		$		$		$	*/

/*9.	Definir un Cursor:
Que actualice el campo observaciones de la tabla historias con las siguientes indicaciónes:
	Repetir estudio: si el mismo se realizó en el segundo instituto registrado en la tabla (orden alfabético).
	Diagnóstico no confirmado: si el mismo se realizó en cualquier otro instituto y fue solicitado por el 
tercer médico de la tabla (orden alfabético).*/

declare @segundoInstituto smallint, @tercerMedico smallint,
		@idinstituto smallint, @matricula smallint, @observacions varchar(50)
DECLARE cursor_Instituto cursor scroll
for select idinstituto 
from instituto


s
order by instituto

open cursor_Instituto 
fetch absolute 2 from cursor_Instituto into @segundoInstituto
if (@@fetch_status <> 0)
	PRINT 'No hay segundo instituto'
close cursor_Instituto
deallocate cursor_Instituto

declare cursor_Medico cursor scroll
for select matricula 
from medicos 
order by nombre, apellido

open cursor_Medico
fetch absolute 3 from cursor_Medico into @tercerMedico
if (@@fetch_status <> 0)
	PRINT 'No hay tercer medico'
close cursor_Medico
deallocate cursor_Medico

declare cursor_actualiza1 cursor
for select observaciones, idinstituto, matricula 
from historias h
for update of observaciones 

open cursor_actualiza1 
fetch next from cursor_actualiza1 into @observaciones, @idinstituto, @matricula
if (@@fetch_status <> 0)
	PRINT 'No estudios'
else 
	while @@fetch_status = 0
	begin
		if (@idinstituto = @segundoInstituto)
		begin
			update historias set observaciones = 'Repetir estudio' 
			where current of cursor_actualiza1
		end
		else if (@matricula = @tercerMedico)
		begin
			update historias set observaciones = 'Diagnóstico no confirmado' 
			where current of cursor_actualiza1
		end	
		fetch next from cursor_actualiza1 into @observaciones, @idinstituto, @matricula
	end
GO



/*10.	Definir un Cursor:
	Que actualice el campo precio de la tabla precios incrementando en un 2% los mismos para cada estudio 
de distinta especialidad a las restantes.
Ej.: 1º especialidad un 2%, 2º especialidad un 4%, ... */

declare @precio float, @idestudio smallint, @cant int
select @precio = 0

declare cursor_actualiza2 cursor
for select idestudio, precio
from precios p
for update of precio

open cursor_actualiza2
fetch next from cursor_actualiza2 into @idestudio,  @precio
if (@@fetch_status <> 0)
	PRINT 'No se actualizó nada'
else 
	while @@fetch_status = 0
	begin
		declare subcursor_actualiza2 cursor
		for select count(*) as cant
		from estuespe ee inner join estudios e on ee.idestudio = e.idestudio
		where e.idestudio = @idestudio
		
		open subcursor_actualiza2 
		fetch next from subcursor_actualiza2 into @cant
		if (@@fetch_status <> 0)
			PRINT 'No se actualizó nada'
		else
		begin
			if (@cant <> 0 )
			begin 
				select @precio = @precio * 1.02 * @cant
				update precios set precio = @precio
				where current of cursor_actualiza2
			end
		end
		close subcursor_actualiza2
		deallocate subcursor_actualiza2
		fetch next from cursor_actualiza2 into  @idestudio, @precio
	end
	close cursor_actualiza2
	deallocate cursor_actualiza2
GO



--TRANSACCIONES

/*1.	Definir una transacción para modificar la sigla y el nombre de una obra social que se inicie desde una stored procedure que recibe los parámetros de la obra social a modificarse.
INPUT: sigla anterior, sigla nueva, nombre nuevo. 
RETURN: codigo de error.

Se deben actualizar en cadena todas las tablas afectadas al proceso, en caso de error se anulará la transacción presentando el mensaje correspondiente y devolviendo un código de error.
Modificar en caso de ser necesario la definición de los atributos de las tablas que impidan la ejecución de la transacción.*/

/*DROP PROCEDURE*/
create procedure tp7_ej1_drop
as
	alter table historial
	drop constraint Historias_fk_3

	alter table afiliados
	drop constraint Afiliados_fk_2


	alter table planes
	drop  constraint Planes_fk

	alter table obrassociales
	drop constraint ObrasSociales_pk		 
	

	alter table coberturas
	drop constraint Coberturas_pk,
		 constraint Coberturas_fk		


/*ADD PROCEDURE*/
create procedure tp7_ej1_add
as
	alter table obrassociales
	add constraint ObrasSociales_pk primary key (sigla)

	alter table planes
	add constraint Planes_fk foreign key (sigla) references obrassociales
		

	alter table afiliados
	add constraint Afiliados_fk_2 foreign key (sigla,nroplan) references planes


	alter table coberturas
	add constraint Coberturas_pk primary key (sigla,nroplan,id_estudio),
		constraint Coberturas_fk foreign key (sigla,nroplan) references planes
		
	alter table historial
	add constraint Historias_fk_3 foreign key (dni,sigla) references afiliados


create procedure tp7_ej1_tran
@siglaNueva char(8),
@siglaVieja char(8),
@nombre char(30),
@cod int OUTPUT
as
	begin transaction 
		update obrassociales
		set sigla=@siglaNueva, nombre=@nombre
		where sigla=@siglaVieja
		if (@@error<>0)
			begin
				print 'Hubo problemas en la actualizacion - ooss'
				set @cod=1
				rollback tran  	
			end
		
		update planes
		set sigla=@siglaNueva
		where sigla=@siglaVieja
		if (@@error<>0)
			begin
				print 'Hubo problemas en la actualizacion - planes'
				set @cod=1
				rollback tran  	
			end

		update coberturas
		set sigla=@siglaNueva
		where sigla=@siglaVieja
		if (@@error<>0)
			begin
				print 'Hubo problemas en la actualizacion - coberturas'
				set @cod=1
				rollback tran  	
			end

		update afiliados
		set sigla=@siglaNueva
		where sigla=@siglaVieja
		if (@@error<>0)
			begin
				print 'Hubo problemas en la actualizacion - afiliados'
				set @cod=1
				rollback tran  	
			end


		update historial
		set sigla=@siglaNueva
		where sigla=@siglaVieja
		if (@@error<>0)
			begin
				print 'Hubo problemas en la actualizacion - historias'
				set @cod=1
				rollback tran  	
			end

		commit transaction


	print 'fin'

----------------

create procedure tp7_ej1
@siglaNueva char(8),
@siglaVieja char(8),
@nombre char(30),
@cod int OUTPUT
as
	exec tp7_ej1_drop
	exec tp7_ej1_tran @siglaNueva,@siglaVieja,@nombre,@cod=@cod output
	exec tp7_ej1_add


select * from obrassociales
select * from planes
select * from coberturas
select * from afiliados
select * from historial
select * from pacientes

declare @codigo int
exec tp7_ej1 '','OS','osde',@cod=@codigo output
print @codigo

/*2.	Definir una transacción que elimine de la Base de Datos a un paciente.
Se anidarán las stored procedures que se necesiten para completar la transacción, que debe incluír los siguientes procesos:
	Eliminar trigger asociado a la tabla historias para la acción de delete, previa verificación de existencia del mismo.
	Volver a afectar dicho trigger al finalizar el proceso de eliminación.
	Crear las tablas ex_pacientes y ex_historias (si no existen) y grabar los datos intervinientes en la eliminación. (los datos correspondientes a la afiliación del paciente se eliminan pero no se registran). Incluír en la tabla ex_pacientes la registración del usuario que invocó la transacción y la fecha.

Se deben eliminar en cadena todas las tablas afectadas al proceso, en caso de error se anulará la transacción presentando el mensaje correspondiente y devolviendo un código de error.*/

alter procedure tp7_ej2_tran
@dni dni,
@idusuario int
as
	begin transaction
	insert ex_historias select * from historial where dni=@dni
	if(@@error<>0)
		begin
			raiserror('error en el insert ex_historias',10,12)
			rollback tran
		end

	delete from historial where dni=@dni
	if(@@error<>0)
		begin
			raiserror('Error en el delete de historias',10,12)
			rollback tran
		end

	delete from afiliados where dni=@dni
	if(@@error<>0)
		begin
			raiserror('Error en el delete de afiliados',10,12)
			rollback tran
		end

	insert ex_pacientes select *,fecha_eliminacion=getdate(),idusuario=@idusuario from pacientes where dni=@dni
	if(@@error<>0)
		begin
			raiserror('Error en el insert ex_pacientes',10,12)
			rollback tran
		end
	
	delete from pacientes
	where dni=@dni
	if(@@error<>0)
		begin
			raiserror('Error en el delete ex_pacientes',10,12)
			rollback tran
		end

	commit transaction


/* CREAR BD */
alter procedure tp7_ej2_crearbd
as
	if not exists (select name from dbo.sysobjects where name='ex_historias')
		begin
			create table ex_historias
			(	
				dni int,
				id_estudio int,
				id_institutos int,
				fecha_del_estudio datetime not null,
				matricula int,
				sigla char(10),
				pagado char(10),
				Resultado char(30),
			)
		end
	
	if not exists (select name from dbo.sysobjects where name='ex_pacientes')
		begin
			create table ex_pacientes
			(
				nombre char(30),
				apellido char(30),
				dni int,
				sexo char(2),
				fecha_de_nacimiento datetime,
				fecha_eliminacion datetime,
				idusuario int,
			)
		end


alter procedure tp7_ej2_off
as
if exists (Select * from sysobjects where xtype='TR' and name='eliminaHistotias')
	begin
		disable trigger eliminaHistotias on Historial
		--drop trigger eliminaHistotias
	end

alter procedure tp7_ej2_on
as
if not exists (Select * from sysobjects where xtype='TR' and name='eliminaHistotias')
	begin
		enable trigger elimniaHistotias on Historial
end

create trigger eliminaHistotias
		on historias
		instead of delete
		as print 'Prohibido borrar historias'
	
	
alter procedure tp7_ej2
@dni dni,
@idusuario int
as
	exec tp7_ej2_off
	exec tp7_ej2_crearbd
	exec tp7_ej2_tran @dni, @idusuario
	exec tp7_ej2_on


exec tp7_ej2 '32090527',1 --PROBAR CON OTRO NUMERO!!

drop table ex_historias
drop table ex_pacientes
select * from ex_historial
select * from ex_pacientes


/*3.	Definir una transacción que elimine lógicamente de la Base de Datos a todos los médicos de una determinada especialidad.
Se anidarán las stored procedures que se necesiten para completar la transacción, que debe tener en cuenta lo siguiente:
	La eliminación del médico debe ser lógica conforme al trigger asociado a la acción de delete. (TP5)
	No se realizará la eliminación del médico si el mismo posee otra especialidad.
	Las historias no serán eliminadas.
	Crear una tabla temporaria donde se registrarán las referencias a los médicos e historias que intervinieron en el proceso.
	Emitir un listado de los datos involucrados en el proceso (grabados en la tabla temporaria), según el sigiente formato:

Usuario responsable
ELIMINACION DE MEDICOS DE LA ESPECIALIDAD X
-------------------------------------------
Dr(a) Nombre Apellido
Fecha y estudio que indicó
Total de estudios
   
En caso de error se anulará la transacción presentando el mensaje correspondiente.(Un error en la emisión del listado no debe anular la transacción de eliminación).*/


/*CURSORES*/
/*Punto 5. CURSORES*/


/*93. Definir un Cursor:
Que liste la ficha de los pacientes de los últimos seis meses conforme al siguiente formato de salida:
Datos del paciente.
Identificación del médico.
Detalle de los estudios realizados.*/

declare cursor_ej1 cursor Forward_Only Read_Only
for
select p.dni, p.nombre, p.apellido, p.sexo, p.nacimiento, m.matricula, e.estudio
	from historias	inner join afiliados on afiliados.nroafiliado = historias.nroafiliado
					inner join pacientes p on p.dni = afiliados.dni
					inner join medicos m on m.matricula = historias.matricula
					inner join institutos on institutos.idinstituto = historias.idinstituto
					inner join precios on precios.idinstituto = institutos.idinstituto
					inner join estudios e on e.idestudio = precios.idestudio



--close cursor_ej1 
open cursor_ej1	
declare
	@dni varchar (8),
	@nombre varchar (100),
	@apellido varchar(100),
	@sexo varchar(100),
	@nacimiento datetime,
	@matricula smallint,
	@estudio varchar(100),
	@dniaux varchar (8),
	@matriculaaux smallint

fetch next from cursor_ej1 into
	@dni, @nombre, @apellido, @sexo, @nacimiento, @matricula, @estudio
set @dniaux = @dni
set @matriculaaux = @matricula
while @@fetch_status = 0
begin
	print 'Paciente: Dni '+@dni+' nombre '+@nombre+' apellido '+@apellido+' sexo '+@sexo+ ' nacimiento '+cast (@nacimiento as varchar(50))
	while @dni = @dniaux and @@fetch_status =0
		begin
			print Space(30)+'Matricula medico: '+cast (@matricula as char)
			while @matriculaaux = @matricula and @@fetch_status =0
				begin
				print Space(50)+'Estudio: '+@Estudio
				
				fetch next from cursor_ej1 into
					@dni, @nombre, @apellido, @sexo, @nacimiento, @matricula, @estudio
				end
			set @matriculaaux = @matricula
		
		end	
		set @dniaux = @dni
end

close cursor_ej1
deallocate cursor_ej1


/*94. Definir un Cursor:
Que liste el detalle de los planes que cubren un determinado estudio identificando el porcentaje cubierto y la obra social, según formato:
Estudio.
Obra social.
Plan y Cobertura (ordenado en forma decreciente). */
declare cursor_ej2 cursor Forward_Only Read_Only
for
select e.estudio, o.nombre, p.nombre, c.cobertura
	from estudios e 
		inner join coberturas c on c.idestudio=e.idestudio
		inner join planes p on p.idplan = c.idplan
		inner join ooss o on o.sigla = p.sigla

--close cursor_ej2
open cursor_ej2

declare 
	@estudio varchar(50),
	@ooss varchar (50),
	@plan varchar (50),
	@cobertura varchar (50),
	@estudioaux varchar(50),
	@oossaux varchar (50)

fetch next from cursor_ej2 into
	@estudio, @ooss, @plan, @cobertura

set @estudioaux = @estudio
set @oossaux = @ooss

while @@fetch_status = 0
	begin
	print 'Nombre del estudio  '+@estudio
	while @@fetch_status = 0 and @estudio = @estudioaux
		begin
		print Space(20)+'Nombre de la obra social  '+@ooss
		while @@fetch_status = 0 and @ooss = @oossaux
			begin
			print Space(50)+'Nombre del plan: '+@plan+'   Cobertura:   '+@cobertura
			fetch next from cursor_ej2 into
				@estudio, @ooss, @plan, @cobertura
			end
		set @oossaux = @ooss
		end
	set @estudioaux = @estudio
	end

close cursor_ej2
deallocate cursor_ej2


/*95. Definir un Cursor:
Que liste la cantidad estudios realizados mostrando parciales por paciente y por instituto, conforme al siguiente detalle:
Datos del paciente
Instituto Cantidad de estudios.
Total de estudios realizados por el paciente.
Total de estudios realizados (todos los pacientes).*/

declare cursor_ej3 cursor Forward_Only Read_Only
for
select p.dni, i.instituto, h.fecha
	from historias h
		inner join afiliados on afiliados.nroafiliado = h.nroafiliado
		inner join pacientes p on p.dni = afiliados.dni
		inner join institutos i on i.idinstituto = h.idinstituto

--close cursor_ej3
open cursor_ej3

declare
	@dni varchar(8),
	@instituto varchar(100),
	@fecha datetime,
	@dniaux varchar(8),
	@institutoaux varchar(100),
	@fechaaux datetime,
	@nombre varchar(100),
	@apellido varchar (100),
	@sexo varchar (10),
	@nacimiento datetime,
	@estudiosinstituto int,--estos son para contar la cantidad de estudios
	@estudiospaciente int,
	@estudiostotales int

fetch next from cursor_ej3 into @dni, @instituto, @fecha

set @dniaux = @dni
set @institutoaux = @instituto
set @fechaaux = @fecha --be or not to be?
set @estudiospaciente = 0 --es necesario???
set @estudiostotales = 0 --es necesario???
set @estudiosinstituto = 0

while @@fetch_status = 0
	begin
	set @nombre = (select pacientes.nombre from pacientes where pacientes.dni = @dni)
	set @apellido = (select pacientes.apellido from pacientes where pacientes.dni = @dni)
	set @sexo =(select pacientes.sexo from pacientes where pacientes.dni = @dni)
	set @nacimiento = (select pacientes.nacimiento from pacientes where pacientes.dni = @dni)
	print 'Datos del paciente:'
	print space(5)+'Dni: '+cast (@dni as VARCHAR(13))+' Nombre: '+@nombre+' Apellido: '+@apellido+' Sexo: '+@sexo+' Fecha Nacimiento: '+cast(@nacimiento as char)
	if @dni = @dniaux and @@fetch_status = 0
		begin
		print space(20)+'Nombre del instituto:'+@instituto
		while @@fetch_status = 0 and @instituto = @institutoaux
			begin
			set @estudiosinstituto = @estudiosinstituto +1
			set @estudiostotales = @estudiostotales +1
			set @estudiospaciente = @estudiospaciente +1
			
			fetch next from cursor_ej3 into @dni, @instituto, @fecha
			end
		set @institutoaux = @instituto
		print space(20)+'Cantidad de estudios en este instituto: '+cast (@estudiosinstituto as char)
		
		set @estudiosinstituto =0
		set @dniaux = @dni
		set @estudiospaciente =0
		end
	
	print space(5)+'Cantidad de estudios por el paciente'+cast (@estudiospaciente as char)
	

	end
print 'Cantidad de estudios totales: '+cast (@estudiostotales as char)

close cursor_ej3
deallocate cursor_ej3
/*96. Definir un Cursor:
Que liste la cantidad estudios solicitados mostrando parciales por estudio 
y por médico, y detalle de los estudios solicitados conforme al siguiente formato:
Datos del médico
Nombre del estudio
Fecha Paciente
Cantidad del estudio
Cantidad de estudios del médico*/

declare cursor_ej4 cursor Forward_Only Read_Only
for

select m.matricula, e.estudio, h.fecha, a.dni
from historias h 
		inner join medicos m on m.matricula = h.matricula
		inner join afiliados a on a.nroafiliado = h.nroafiliado
		inner join institutos on institutos.idinstituto = h.idinstituto
		inner join precios on precios.idinstituto = institutos.idinstituto
		inner join estudios e on e.idestudio = precios.idestudio

open cursor_ej4

declare
	@matricula smallint,
	@estudio varchar (100),
	@fecha datetime,
	@dni varchar(8),
	@matriculaaux smallint,
	@estudioaux varchar (100),
	@nombre varchar(100),
	@apellido varchar (100),
	@activo varchar (100),
	@sexo varchar (100)

fetch next from cursor_ej4 into @matricula, @estudio, @fecha, @dni
set @matriculaaux = @matricula
set @estudioaux = @estudio

while @@fetch_status = 0
	begin
		set @nombre = (select medicos.nombre from medicos where @matricula = medicos.matricula)
		set @apellido = (select medicos.apellido from medicos where @matricula = medicos.matricula)
		set @activo = (select medicos.activo from medicos where @matricula = medicos.matricula)
		set @sexo = (select medicos.sexo from medicos where @matricula = medicos.matricula)
		print 'Datos del medico: '
		print space(5)+'Matricula: '+cast (@matricula as char)+' Nombre: '+cast(@nombre as char)+' Apellido: '+cast (@apellido as char)+' Condicion: '+@activo+' Sexo: '+@sexo
		while @@fetch_status = 0 and @matricula=@matriculaaux
		begin
			
			while @@fetch_status = 0 and @estudio = @estudioaux
				begin
				print space(10)+'Nombre del estudio: '+@estudio
				print space(15)+'Fecha: '+cast (@fecha as char)+'Paciente: '+@dni
				fetch next from cursor_ej4 into @matricula, @estudio, @fecha, @dni
				end
			set @estudioaux = @estudio	

		end
	set @matriculaaux = @matricula
	end

close cursor_ej4
deallocate cursor_ej4



/* 97. Crear una Stored Procedure que defina un Cursor:
Que liste el resumen mensual de los importes a cargo de una obra social.
INPUT: nombre de la obra social, mes y año a liquidar.
Obra social
Nombre del Instituto
Detalle del estudio
Subtotal del Instituto
Total de la obra social*/
/*RECIBE SIGLA DE LA OOSS*/
declare
	@flocha datetime
set @flocha = '2010-09-01'
execute usp_Ejercicio97 'osde', @flocha


drop procedure usp_ejercicio97
--Aca empieza el procedure, lo de arriba es para provarlo (provar va con B? )
/*Estan mal los datos cargados en las tablas, pero anda bien. Debugeado*/

create procedure usp_Ejercicio97 
		@sigla varchar(8),
		@fecha datetime
as
declare cursor_ejercicio97 cursor Scroll 
for
/* para provar el select del cursor*/
/*

declare
	@fecha datetime,
	@sigla varchar(8)
	set @sigla = 'osde'
set @fecha = '2010-09-01'
*/

select historias.fecha, historias.idinstituto, historias.idestudio,  precios.precio, historias.porcentaje_cubierto
	from historias inner join institutos on institutos.idinstituto = historias.idinstituto
			inner join precios on precios.idinstituto = institutos.idinstituto
	where historias.sigla = @sigla and datediff(dd, @fecha, historias.fecha) <= 30 and  datediff(dd, @fecha, historias.fecha) >= -30


/*tabla auxiliar con las fechas que ya pase por pantalla*/

open cursor_ejercicio97

declare
	@fecha2 datetime,
	@idestudio smallint,
	@idinstituto smallint,
	@precio smallint,
	@porcentaje_cubierto float,
	@idinstitutoaux smallint,
	@estudio varchar(100),
	@preciototalooss float,
	@preciototalinst float,
	@nombreinst varchar(100),
	@idestudioaux smallint,
	@contadorfilascursor int,
	@contadorfilasaux int,
	@contadorfetch int

create table aux
( fecha datetime )
set @preciototalooss = 0
set @preciototalinst = 0

fetch next from cursor_ejercicio97 into @fecha2,  @idinstituto, @idestudio, @precio, @porcentaje_cubierto
set @idinstitutoaux = @idinstituto
set @idestudioaux =@idestudio
set @contadorfetch = 2
/*Con esto cuento las filas del cursor, no sabia hacerlo en la condicion del otro while, me tiraba error....*/


set @contadorfilascursor = 1
While @@FETCH_STATUS = 0
begin
set @contadorfilascursor = @contadorfilascursor +1
fetch next from cursor_ejercicio97 into @fecha2,  @idinstituto, @idestudio, @precio, @porcentaje_cubierto

end
fetch absolute 1 from cursor_ejercicio97 into @fecha2,  @idinstituto, @idestudio, @precio, @porcentaje_cubierto
set @contadorfilasaux = 0


while @@FETCH_STATUS = 0 and @contadorfilasaux<= @contadorfilascursor
	begin

		print 'Obra social: '+@sigla
		while @@fetch_status = 0
			begin 
				set @nombreinst = (select institutos.instituto from institutos where idinstituto = @idinstituto)
				print space(3)+'Instituto: ' + @nombreinst
				while @@fetch_status = 0 
					begin

						if @fecha2 in (select * from aux)
						begin
							fetch next from cursor_ejercicio97 into @fecha2,  @idinstituto, @idestudio, @precio, @porcentaje_cubierto

						end
						else
						begin
							if @idinstituto <> @idinstitutoaux 
							begin
								fetch next from cursor_ejercicio97 into @fecha2,  @idinstituto, @idestudio, @precio, @porcentaje_cubierto

							end
							else
							begin

							insert into aux values (@fecha2);
							set @contadorfilasaux = @contadorfilasaux +1
							set @estudio = (select estudios.estudio from estudios where estudios.idestudio = @idestudio)
							print 'Detalle del estudio: '+ @estudio
							set @preciototalinst = @preciototalinst + (@precio * @porcentaje_cubierto / 100)
							set @preciototalooss = @preciototalooss + @preciototalinst
							fetch next from cursor_ejercicio97 into @fecha2,  @idinstituto, @idestudio, @precio, @porcentaje_cubierto
							
							end
						end
				
					end			print space(3)+'Total instituto: '+ cast (@preciototalinst as char)
				set @preciototalinst = 0	

			end
		print space (4)+'Total Obra Social: '+cast(@preciototalooss as char)
		fetch absolute @contadorfetch from cursor_ejercicio97 into @fecha2,  @idinstituto, @idestudio, @precio, @porcentaje_cubierto
		set @contadorfetch = @contadorfetch +1
		set @idinstitutoaux = @idinstituto
	end
drop table aux
close cursor_ejercicio97
deallocate cursor_ejercicio97



go
/*98. Definir un Cursor:
Que devuelva una tabla de referencias cruzadas que exprese la cantidad de estudios 
realizados por los pacientes de una determinada obra social discriminando por plan.
INPUT: obra social.
Obra Social: nombre de la obra social
					Plan A Plan B Plan C
		Estudio 1	n        n	   -
		Estudio 2   n        -     n*/

declare @siglainput char(8)
set @siglainput='osde' --Aca hardcodeamos el ingreso del parametro
declare cursor_ej98Estudios cursor Forward_Only Read_Only
for
select estudios.idestudio, estudios.estudio 
	from estudios 


open cursor_ej98Estudios
declare 
	@idestudio smallint,
	@estudio varchar(100)
fetch next from cursor_ej98Estudios into @idestudio, @estudio
while @@fetch_status = 0
begin
	print 'Obra Social: '+@siglainput
	set @estudio = (select estudios.estudio from estudios where estudios.idestudio = @idestudio)
	print 'Estudio: '+cast (@estudio as char)
	declare cursor_ej98Planes cursor Forward_Only Read_Only
	for
	select planes.idplan, count(1) as total
	from planes
	inner join afiliados on afiliados.idplan=planes.idplan
	inner join historias on historias.nroafiliado = afiliados.nroafiliado
	where planes.sigla=@siglainput
	and historias.idestudio=@idestudio
	group by planes.idplan
	union
	select planes.idplan, 0 as total
	from planes
	where idplan not in (select idplan 
							from afiliados 
							inner join historias on historias.nroafiliado = afiliados.nroafiliado
							where historias.idestudio=@idestudio)
	and planes.sigla=@siglainput


	open cursor_ej98Planes

	declare /*variables*/
	@contador int,
	@idplanint smallint

	fetch next from cursor_ej98Planes into @idplanint, @contador
	while @@fetch_status = 0
		begin
			print space (5)+'Plan: '+cast (@idplanint as char)+'Cantidad: '+cast (@contador as char)
			fetch next from cursor_ej98Planes into @idplanint, @contador

		end
	close cursor_ej98Planes
	deallocate cursor_ej98Planes
fetch next from cursor_ej98Estudios into @idestudio, @estudio

end


close cursor_ej98Estudios
deallocate cursor_ej98Estudios














/*
99. Crear una Stored Procedure que defina un Cursor:
Que devuelva una tabla de referencias cruzadas que exprese la cantidad de estudios realizados por institutos en un determinado período.
INPUT: fecha desde, fecha hasta.
Período: del nn/nn/nn al nn/nn/nn
Estudio I Estudio II Estudio III
Inst. A n n -
Inst. B n - n

*/

insert into precios values(2,1,100,8);
insert into precios values(3,1,100,9);

/*para provar*/
declare
	@fecha1 datetime
	@fecha2 datetime
set @fecha1 = '2010-08-10'
set @fecha2 = '2010-11-23'
execute usp_ejercicio99 '2010-09-01', '2010-11-23'

drop procedure usp_ejercicio99

/*ACA EMPIEZA EL 99*/

create procedure usp_ejercicio99
	@fechadesde datetime,
	@fechahasta datetime
as
declare cursor_ejercicio99 cursor scroll
for
	/* Para provar el select
		declare @fechadesde datetime, @fechahasta datetime
		set @fechadesde = '2010-09-15'
		set @fechahasta = '2010-11-23'*/


select historias.idinstituto,historias.idestudio, count (idestudio)as total
from historias
where  datediff(dd, historias.fecha, @fechadesde) <= 30 and datediff(dd, @fechahasta,  historias.fecha) <= 30
group by historias.idinstituto, historias.idestudio
union
select institutos.idinstituto,historias.idestudio, 0 as total
from institutos inner join historias on historias.idinstituto = institutos.idinstituto
where institutos.idinstituto not in (select idinstituto from historias 
				where datediff(dd, historias.fecha, @fechadesde) <= 30 and datediff(dd, @fechahasta,  historias.fecha) <= 30)
group by institutos.idinstituto, historias.idestudio

union

select institutos.idinstituto, estudios.idestudio, 0 as total
from institutos inner join precios on precios.idinstituto = institutos.idinstituto
				inner join estudios on estudios.idestudio = precios.idestudio
group by institutos.idinstituto, estudios.idestudio


open cursor_ejercicio99
 
declare
	@estudio varchar(100),
	@instituto varchar(100),
	@idinstituto smallint,
	@idestudio smallint,
	@idestudioaux smallint,
	@idinstitutocomparacion smallint,
	@idestudiocomparacion smallint,
	@idinstitutoaux smallint,
	@totalcomparacion int,
	@total int

fetch next from cursor_ejercicio99 into @idinstituto, @idestudio, @total
set @idestudioaux = @idestudio
set @idinstitutoaux = @idinstituto

while @@FETCH_STATUS =0
	begin
	set @instituto = (select institutos.instituto from institutos where @idinstituto = institutos.idinstituto)
	print 'Instituto: '+cast (@instituto as char)
	while @@FETCH_STATUS = 0 and @idinstitutoaux = @idinstituto
		begin
		
		set @estudio = (select estudios.estudio from estudios where @idestudio = estudios.idestudio)
		fetch relative 1 from cursor_ejercicio99 into @idinstitutocomparacion , @idestudiocomparacion, @totalcomparacion
		if @idinstituto = @idinstitutocomparacion and @idestudio = @idestudiocomparacion
			begin
				print space(5)+'Estudio: '+cast (@estudio as char)+'Total: '+cast (@totalcomparacion as char)
				fetch next from cursor_ejercicio99 into @idinstituto, @idestudio, @total
			end
			else
			begin
				print space(5)+'Estudio: '+cast (@estudio as char)+'Total: '+cast (@total as char)
				set @idinstituto = @idinstitutocomparacion
				set @idestudio = @idestudiocomparacion
				set @total = @totalcomparacion
			end
		end
		
	set @idinstitutoaux = @idinstituto

	end
close cursor_ejercicio99
deallocate cursor_ejercicio99

go

/*
100. Crear una Stored Procedure que defina un Cursor:
Que devuelva una tabla de referencias cruzadas que represente el importe mensual abonado a cada 
instituto en los últimos n meses.
INPUT: entero que representa los n meses anterioes.
		Mes año Mes año Mes año Mes año Total Inst.
Inst. A -		 -		 $		$		 $
Inst. B $ $ - $ $
Total $ $ $ $ $*/

create procedure usp_ejercicio100
	@nmesesanteriores int
as


declare cursor_ejercicio100 cursor scroll
for

select historias.idinstituto, historias.fecha, precios.precio, historias.porcentaje_cubierto
from historias	inner join institutos on institutos.idinstituto = historias.idinstituto
				inner join precios on precios.idinstituto = historias.idinstituto
where datediff(mm,historias.fecha,getdate()) <= @nmesesanteriores
order by historias.idinstituto, historias.fecha
declare
	@idinstituto smallint,
	@fecha datetime,
	@precio float,
	@porcentaje_cubierto float
fetch next from cursor_ejercicio100 into @idinstituto, @fecha, @precio, @porcentaje_cubierto

while @@FETCH_STATUS =0 
	begin
	
	




	end



/*
101. Definir un Cursor:
Que actualice el campo observaciones de la tabla historias con las siguientes indicaciónes:
Repetir estudio: si el mismo se realizó en el segundo instituto registrado en la tabla (orden alfabético).
Diagnóstico no confirmado: si el mismo se realizó en cualquier otro instituto y fue solicitado por el tercer
 médico de la tabla (orden alfabético).*/

declare @segundoInstituto smallint, 
		@tercerMedico smallint,
		@idinstituto smallint, 
		@matricula smallint, 
		@observaciones varchar(50)
DECLARE cursor_Instituto cursor scroll
for select idinstituto 
from institutos
order by instituto

open cursor_Instituto 
fetch absolute 2 from cursor_Instituto into @segundoInstituto
if (@@fetch_status <> 0)
	PRINT 'No hay segundo instituto'
close cursor_Instituto
deallocate cursor_Instituto

declare cursor_Medico cursor scroll
for select matricula 
from medicos 
order by nombre, apellido

open cursor_Medico
fetch absolute 3 from cursor_Medico into @tercerMedico
if (@@fetch_status <> 0)
	PRINT 'No hay tercer medico'
close cursor_Medico
deallocate cursor_Medico

declare cursor_actualiza1 cursor
for select observaciones, idinstituto, matricula 
from historias h
for update of observaciones 

open cursor_actualiza1 
fetch next from cursor_actualiza1 into @observaciones, @idinstituto, @matricula
if (@@fetch_status <> 0)
	PRINT 'No estudios'
else 
	while @@fetch_status = 0
	begin
		if (@idinstituto = @segundoInstituto)
		begin
			update historias set observaciones = 'Repetir estudio' 
			where current of cursor_actualiza1
		end
		else if (@matricula = @tercerMedico)
		begin
			update historias set observaciones = 'Diagnóstico no confirmado' 
			where current of cursor_actualiza1
		end	
		fetch next from cursor_actualiza1 into @observaciones, @idinstituto, @matricula
	end
	close cursor_actualiza1
	deallocate cursor_actualiza1
GO


/*102. Definir un Cursor:
Que actualice el campo precio de la tabla precios incrementando en un 2% los mismos para cada estudio 
de distinta especialidad a las restantes.
Ej.: 1º especialidad un 2%, 2º especialidad un 4%, ...*/
select * from precios
declare @precio float, @idestudio smallint, @cant int
select @precio = 0

declare cursor_actualiza2 cursor
for select idestudio, precio
from precios p
for update of precio

open cursor_actualiza2
fetch next from cursor_actualiza2 into @idestudio,  @precio
if (@@fetch_status <> 0)
	PRINT 'No se actualizó nada'
else 
	while @@fetch_status = 0
	begin
		declare subcursor_actualiza2 cursor
		for select count(*) as cant
		from estuespe ee inner join estudios e on ee.idestudio = e.idestudio
		where e.idestudio = @idestudio
		
		open subcursor_actualiza2 
		fetch next from subcursor_actualiza2 into @cant
		if (@@fetch_status <> 0)
			PRINT 'No se actualizó nada'
		else
		begin
			if (@cant <> 0 )
			begin 
				select @precio = @precio * 1.02 * @cant
				update precios set precio = @precio
				where current of cursor_actualiza2
			end
		end
		close subcursor_actualiza2
		deallocate subcursor_actualiza2
		fetch next from cursor_actualiza2 into  @idestudio, @precio
	end
	close cursor_actualiza2
	deallocate cursor_actualiza2
GO

