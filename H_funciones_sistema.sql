getdate()
select getdate()

datepart( parte, date)
select datepart(mm, getdate())

year	yy	año
month	mm	numero del mes
weak	wk	numero de la semana
day	dd	dia del mes
dayofyear	dy	dia del año
weekday	wd	dia de la semana
hour	hh	hora del dia
minute	mi	minutos
second	ss	segundos
milisecond	ms	milisegundos

datename( parte, date)
select datename(dw, getdate())

dateadd( parte, entero, expresion fecha )
select datename(dd, 2, getdate())

datediff( parte, expresion fecha, expresion fecha )
select datediff(dd, fecha, getdate())



convert( tipo, expresion )
select convert( char(8), 53678.82)
select convert(numeric(10,2), '53046.78') + 1

convert( tipo, fecha, estilo )
select convert( char(12), getdate(),3)

isdate( string )
select isdate('10/01/2003')
 
valor devuelto: 1
Retorna un 1 si es una fecha o un 0 si no lo es..

isnull( expresion1, expresion2 )
select isnull(valor, 0)

isnumeric( expresion )
select isnumeric('120')
 
valor devuelto: 1
Retorna 1 si es un numero o 0 si no lo es.

user_name( )
select user_name()



abs( numero )
Retorna el valor absoluto de un numero.
ceiling( numero )
floor( numero )
select floor(9.23)
valor devuelto: 9
Retorna el primer entero menor al numero.
power( numero, entero )
rand( )
round( flotante, entero )
sign( numero )
sqrt( numero )



len( string )
charindex( string, string, [entero] )
lower( string )
replicate( string, entero )
left( string, entero)
right( string, entero)
ltrim( string )
rtrim( string )
str( flotante, entero, [entero] )
substring( string, entero, entero )
upper( string )
