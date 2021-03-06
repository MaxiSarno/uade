use jugadores
go

--funcion que devuelva cuantas variables del tipo hay en la tabla
--miBase>Views>SystemTables

create function fu1 (@nomTabla varchar(20), @tipoDato varchar(20))
returns int
as
begin
	return (select count(*)
			from sys.tables tab 
				join sys.columns col on col.object_id=tab.object_id
				join sys.types typ on typ.system_type_id = col.system_type_id
			where tab.name = @nomTabla and typ.name = @tipoDato)
end
go

select dbo.final11('general','smallint')

select * from sys.objects
select * from sys.tables
select * from sys.columns
select * from sys.types

--procedure loco
--correr esto para poder hacer updates
sp_configure 'allow updates',0
go
reconfigure
go
--------------------

create procedure final12
	@nomClub varchar(20),
	@cat int,
	@canClubes int output
as
	declare @idClub varchar(30), @mejor varchar(30), @nroZona int
	select @idClub=Id_Club from Clubes where @nomClub=Nombre
	select @nroZona=Nrozona from Clubes where @nomClub=Nombre

	select @mejor=g.Id_Club from General g where g.Puntos= 
		(select max(g1.puntos) from general g1 where g1.Id_Club in 
			(select Id_Club from clubes c where c.Nrozona=@nroZona))
	
	if (@cat=84)
	begin
		(select * from PosCate184
		union all
		select * from PosCate284)
	end

	if (@cat=85)
	begin
	end
go

select * from 
(select * from PosCate184
union all
select * from PosCate284)
where id_club not in

select * from General g1
select * from PosCate184
select * from PosCate284
select * from Clubes

begin
declare @tabla varchar(30)
set @tabla='PosCate184'
select * from @tabla
end
go

--sql dinamico
declare @sql nvarchar(max), @paramDef nvarchar(100)
set @paramDef = '@login varchar(20), @usuario varchar(20), @tabla varchar(20)'
set @sql='
declare @login varchar(20), @usuario varchar(20), @tabla varchar(20)
declare @id int
set @usuario=''godio''
set @tabla=''especialidadesasd''

select @id=uid from sys.sysusers where name = @usuario
if (@id is not null)
begin
	print ''alala''
	--delete from sys.sysusers where uid=@id
end

select @id=name from sys.tables where name = @tabla
select @id=uid from sys.sysusers where name = @usuario
if (@id is null)
begin
	raiserror(''no existe la tabla'',1,1)
end

create user @usuario for login @login
sp_addrolemember ''db_datareader'',@usuario
'
EXECUTE sp_executesql @sql, @paramDef, @login='BANEGAS, MAURICIO'


--la consulta del sql dinamico
declare @login varchar(20), @usuario varchar(20), @tabla varchar(20)
declare @id int
set @usuario='godio'
set @tabla='especialidadesasd'

select @id=uid from sys.sysusers where name = @usuario
if (@id is not null)
begin
	print 'alala'
	--delete from sys.sysusers where uid=@id
end

select @id=name from sys.tables where name = @tabla
select @id=uid from sys.sysusers where name = @usuario
if (@id is null)
begin
	raiserror('no existe la tabla',1,1)
end

create user @usuario for login @login
sp_addrolemember 'db_datareader',@usuario

??
select * from sys.syspermissions


--cursores
drop procedure final14
create procedure final14
	@message varchar(20)
as
	declare @cantClubes int, @cantJug int, @idc int, @nom varchar(20)
	set @cantClubes = 0

	declare cursorClubes cursor for select Id_Club from clubes c
	open cursorClubes
	fetch next from cursorClubes into @idc

	while (@@FETCH_STATUS=0)
	begin
		set @cantJug = 0
		set @cantClubes = @cantClubes +1
		
		declare cursorJugadores cursor for select Nombre from jugadores j where j.Id_Club=@idc
		open cursorJugadores
		fetch next from cursorJugadores into @nom

		while (@@FETCH_STATUS=0)
		begin
			set @cantJug = @cantJug + 1
			fetch next from cursorJugadores into @nom
		end

		
		close cursorJugadores
		deallocate cursorJugadores

		print @message+' club:'+convert(varchar(20),@idc)+' cantJug:'+convert(varchar(20),@cantJug)
		fetch next from cursorClubes into @idc
	end
	print @message+' clubes:'+convert(varchar(20),@cantClubes)

	close cursorClubes
	deallocate cursorClubes
go

exec final14 @message='hola'


create trigger tiger on jugadores
after delete
as
	declare @cant int
	select @cant=count(*) from deleted
	select isnull(@cant,0)

	if(@cant>1)
	begin
		print 'mas de una fila'
	end

	rollback transaction
go

select * from jugadores
delete  from jugadores where Id_Club=6
if OBJECT_ID('final14') is not null
	print 'hola'