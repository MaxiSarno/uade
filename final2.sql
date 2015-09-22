if OBJECT_ID('empatesZona2') is not null
	drop view empatesZona2


create view empatesZona2
as
	select * from partidos p 
	where p.GolesL=p.GolesV
		and p.Id_ClubL in (select id_club from Clubes where Nrozona=2)
		and p.Id_ClubV in (select id_club from Clubes where Nrozona=2)
go

select * from empateszona2

select p.nroFecha from empateszona2 p
group by p.NroFecha
having count(p.nroFecha) >= all (
	select count(p1.nroFecha) from empateszona2 p1
	group by p1.NroFecha)



begin transaction unica
	
	if OBJECT_ID('unicaFunc') is not null
		drop function unicaFunc
	go
	
	create function unicaFunc ()
	returns int
	as
	begin
		declare @nroFecha int

		select @nroFecha=e.nroFecha from empateszona2 e
		group by e.nroFecha
		having count(e.nroFecha) > all 
			(select e1.nroFecha from empateszona2 e1
			group by e1.nroFecha
			having count(e1.nroFecha) > count(e.nroFecha))					


		return @nroFecha
	end
	go



select * from empateszona2

select e.nroFecha from empateszona2 e
group by e.nroFecha
having count(e.nroFecha) > all 
	(select e1.nroFecha from empateszona2 e1
	group by e1.nroFecha
	having count(e1.nroFecha) > count(e.nroFecha))