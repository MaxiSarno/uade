
declare
Define los atributos de un cursor de servidor, como su comportamiento de desplazamiento y la consulta utilizada para generar el conjunto de resultados sobre el que opera el cursor.


DECLARE nombre_cursor CURSOR 
[ LOCAL | GLOBAL ] 
[ FORWARD_ONLY | SCROLL ] 
[ STATIC | KEYSET | DYNAMIC | FAST_FORWARD ] 
[ READ_ONLY | SCROLL_LOCKS | OPTIMISTIC ] 
[ TYPE_WARNING ] 
FOR Select... 
[ FOR UPDATE [ OF columna [ ,...n ] ] ] 

Argumentos:
Local 	Especifica que el alcance del cursor es local para el proceso por lotes, procedimiento almacenado o desencadenador en que se creó el cursor. El nombre del cursor sólo es válido dentro de este alcance.
Global 	Especifica que el alcance del cursor es global para la conexión. Puede hacerse referencia al nombre del cursor en cualquier procedimiento almacenado o proceso por lotes que se ejecute durante la conexión. Sólo se cancela implícitamente la asignación del cursor cuando se realiza la desconexión.
Forward-Only 	Especifica que el cursor sólo se puede desplazar desde la primera a la última fila.
Scroll 	Especifica que están disponibles todas las opciones de recuperación (FIRST, LAST, PRIOR, NEXT, RELATIVE, ABSOLUTE).
Static 	Define un cursor que hace una copia temporal de los datos que utiliza.
Todas las peticiones al cursor se responden desde esta tabla temporal de tempdb; por ello, las modificaciones realizadas en las tablas base no se reflejarán en los datos obtenidos en las recuperaciones realizadas en el cursor y además este cursor no admite modificaciones.
Keyset 	Es un conjunto de claves que identifica de forma única las filas del cursor.
Se integran en una tabla de tempdb conocida como keyset. Los cambios en valores que no sean claves de las tablas base, ya sean realizados por el propietario del cursor o confirmados por otros usuarios, son visibles cuando el propietario se desplaza por el cursor. Las inserciones realizadas por otros usuarios no son visibles. Las eliminaciones generan un error (-2 en @Fetch_Status) al intentar recuperarlas. Si se realizan actualizaciones de los valores claves (desde fuera del cursor), los nuevos valores no son visibles y el intento de recuperar los antiguos genera un error (-2 en @Fetch_Status).
Dynamic 	Define un cursor que, al desplazarse por él, refleja en su conjunto de resultados todos los cambios realizados en los datos de las filas.
Fast-Forward 	Especifica un cursor FORWARD_ONLY, READ_ONLY con las optimizaciones de rendimiento habilitadas.
No se puede especificar FAST_FORWARD si se especifica también SCROLL o FOR_UPDATE.
FAST_FORWARD y FORWARD_ONLY se excluyen mutuamente: si se especifica uno, no se puede especificar el otro.
Read-Only 	Evita que se efectúen actualizaciones a través de este cursor.
Scroll-Locks 	Especifica que el éxito de las actualizaciones o eliminaciones con posición, realizadas a través del cursor, está garantizado. Microsoft® SQL Server™ bloquea las filas al leerlas en el cursor, lo que asegura su disponibilidad para posteriores modificaciones.
No es posible especificar SCROLL_LOCKS si se incluye también FAST_FORWARD.
Optimistic 	Especifica que las actualizaciones o eliminaciones con posición realizadas a través del cursor no tendrán éxito si la fila se ha actualizado después de ser leída en el cursor.
No es posible especificar OPTIMISTIC si se incluye también FAST_FORWARD.
Type-Warning 	Especifica que se envía un mensaje de advertencia al cliente si el cursor se convierte implícitamente del tipo solicitado a otro.
Declara una variable tipo cursor.


DECLARE @cursor1 CURSOR
...

Crea un cursor y le define el conjunto de resultados.


DECLARE CursorEmp CURSOR FOR
SELECT LastName FROM Northwind.dbo.Employees
...

Crea un cursor y le define el conjunto de resultados navegable.


DECLARE CursorAut SCROLL CURSOR FOR
SELECT au_lname, au_fname FROM authors
...


set cursor
Establece el valor indicado en la variable local especificada, creada previamente con la instrucción DECLARE @local_variable.


SET { { @variable_cursor = { @variable_cursor | nombre_cursor 
       | { CURSOR [ FORWARD_ONLY | SCROLL ] 
                 [ STATIC | KEYSET | DYNAMIC | FAST_FORWARD ] 
                 [ READ_ONLY | SCROLL_LOCKS | OPTIMISTIC ] 
                 [ TYPE_WARNING ] 
           FOR sentencia Select 
           [ FOR { READ ONLY | UPDATE [ OF columna [ ,...n ] ] } ] 
         } 
    } } 

Declaración y asignación directa de una variable CURSOR.


DECLARE @Var1 CURSOR
SET @Var1 = CURSOR SCROLL KEYSET FOR
SELECT LastName FROM Northwind.dbo.Employees
...


deallocate
Quita una referencia a un cursor. Cuando se ha quitado la última referencia al cursor, se liberan las estructuras de datos que componen el cursor.


DEALLOCATE { { [ GLOBAL ] nombre_cursor} | @variable_cursor }
 
Quita las estructuras de datos asignadas al cursor.


DECLARE cursorX CURSOR FOR ...
...
DEALLOCATE cursorX
GO


open
Abre un cursor del servidor y lo llena ejecutando la instrucción especificada en la instrucción DECLARE CURSOR o SET cursor_variable.


OPEN { { [ GLOBAL ] nombre_cursor} | @variable_cursor }
 
Abre el cursor y lo asocia a la instrucción DECLARE del mismo.


DECLARE cursorX CURSOR FOR ...
OPEN cursorX
...


close
Cierra un cursor abierto liberando el conjunto actual de resultados y todos los bloqueos mantenidos sobre las filas en las que está colocado el cursor. CLOSE deja las estructuras de datos accesibles para que se puedan volver a abrir, pero las recuperaciones y las actualizaciones con posición no se permiten hasta que se vuelva a abrir el cursor. CLOSE se tiene que ejecutar sobre un cursor abierto.


CLOSE { { [ GLOBAL ] nombre_cursor} | @variable_cursor }
 
Cierra el cursor abierto por la instrucción open.


...
CLOSE cursorX
DEALLOCATE cursorX


fetch
Obtiene una fila específica de un cursor del servidor.


FETCH 
        [ [ NEXT | PRIOR | FIRST | LAST 
                | ABSOLUTE { n | @nvar } 
                | RELATIVE { n | @nvar } 
            ] 
            FROM 
        ] 
{ { [ GLOBAL ] nombre_cursor } | @variable_cursor } 
[ INTO @variable [ ,...n ] ] 

Lee la fila siguiente y actualiza las variables asociadas.

DECLARE CursorAut CURSOR 
FOR SELECT au_lname, au_fname FROM authors

OPEN CursorAut

FETCH NEXT FROM CursorAut 
INTO @Nombre_autor, @Apellido_autor
...

Fila anterior a la posición actual del cursor.

...
FETCH PRIOR FROM cursor_autores
...

Segundo registro del cursor (Contado a partir del COMIENZO del cursor)

...
FETCH ABSOLUTE 2 FROM cursor_autores
...

Segundo registro del cursor (Contado a partir del FINAL del cursor)

...
FETCH ABSOLUTE -2 FROM cursor_autores
...

Segundo registro del cursor a partir de la POSICION ACTUAL del cursor.

...
FETCH RELATIVE 2 FROM cursor_autores
...

Segundo registro anterior del cursor a partir de la POSICION ACTUAL del cursor.

...
FETCH RELATIVE -2 FROM cursor_autores
...


@@fetch_status
Devuelve el estado de la última instrucción FETCH de cursor ejecutada sobre cualquier cursor que la conexión haya abierto.


@@fetch_status
 
Controla de posicionamieno del cursor y muestra un mensaje de error.

...
OPEN CursorAut

FETCH NEXT FROM CursorAut 
INTO @Nombre_autor, @Apellido_autor

IF @@FETCH_STATUS <> 0 
   PRINT space(20)+'== NO EXISTEN AUTORES QUE CUMPLAN LA CONDICION =='  
...


current of
Cláusula de las sentencias UPDATE o DELETE.
Indica que se realice la actualización o la eliminación en la posición actual del cursor especificado.


WHERE CURRENT OF { { [ GLOBAL ] nombre_cursor } | @variable_cursor }
 
Elimina la fila correspondiente a la ubicación actual del cursor.

...
FETCH NEXT FROM Cursor_Empleados

DELETE Empleados
WHERE CURRENT OF Cursor_Empleados
...


Define un cursor que recorre la tabla TITLES y lista todos los que son de tipo BUSINESS.

   USE pubs
   DECLARE @titulo char(52), @precio money, @mensaje varchar(90)

   DECLARE Cursor_titulos CURSOR FORWARD_ONLY READ_ONLY
   FOR SELECT title, price FROM titles WHERE type = 'business'
   
   -- Se cargan los datos en el cursor y se posiciona el puntero
   -- de registro ANTES del primer registro existente en el cursor
   OPEN Cursor_titulos
   
   -- SIEMPRE es necesario ejecutar al menos una vez la instrucción
   -- FETCH para leer el primer registro del cursor.
   FETCH NEXT FROM Cursor_titulos INTO @titulo, @precio
   
   -- @@FETCH_STATUS es > 0 el cursor no tiene registros o se
   -- alcanzó el final del cursor
   IF @@FETCH_STATUS <> 0 
        PRINT space(20)+'== NO TIENE LIBROS PUBLICADOS =='
   ELSE
        PRINT space(5)+'== LIBROS PUBLICADOS DE NEGOCIOS =='     

   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @mensaje = Space(20) + @titulo + '   $ ' + convert(varchar(20),@precio)
      PRINT @mensaje
      FETCH NEXT FROM Cursor_titulos INTO @titulo, @precio
   END
   
   -- Se crea y elimina un CURSOR para cada conjunto
   -- de libros publicados por cada autor.
   CLOSE Cursor_titulos
   DEALLOCATE Cursor_titulos
   GO


Declara un cursor navegable a la tabla AUTORES que permite acceder a una fila en forma no secuencial.

USE pubs

-- Declaración del cursor.
DECLARE authors_cursor CURSOR SCROLL
FOR
SELECT au_lname, au_fname FROM authors ORDER BY au_lname, au_fname

OPEN authors_cursor

-- Ultimo registro del cursor
FETCH LAST FROM authors_cursor

-- Registro anterior a la posición actual del cursor (último -1)
FETCH PRIOR FROM authors_cursor

-- Segundo registro del cursor (Contado a partir del comienzo del cursor)
FETCH ABSOLUTE 2 FROM authors_cursor

-- Quinto registro del cursor (Contado a partir del final del cursor)
FETCH ABSOLUTE -5 FROM authors_cursor

-- Segundo registro a partir de la posición actual
FETCH RELATIVE 2 FROM authors_cursor

-- Lee el registro que se encuentra tres posiciones antes de la 
-- posición actual.
FETCH RELATIVE -3 FROM authors_cursor

CLOSE authors_cursor
DEALLOCATE authors_cursor
GO


Declara un cursor que recupera el CAMPO1 de la TABLA1 y modifica el valor de esa columna en la primera fila.


DECLARE cursor1 CURSOR  
FOR
SELECT campo1 FROM tabla1

OPEN cursor1
FETCH NEXT FROM cursor1

UPDATE tabla1 SET campo1 = 'valor actualizado'
WHERE CURRENT OF cursor1

CLOSE cursor1 
DEALLOCATE cursor1
GO

Declara un cursor que recupera el CAMPO1 de la TABLA1 y modifica el valor de esa columna en la primera fila.


DECLARE cursor1 CURSOR OPTIMISTIC
FOR
SELECT campo1, campo2 FROM tabla1
FOR UPDATE OF campo2

OPEN cursor1
FETCH NEXT FROM cursor1

UPDATE tabla1 SET campo2 = 'valor actualizado'
WHERE CURRENT OF cursor1

CLOSE cursor1 
DEALLOCATE cursor1
GO


Declara un cursor que recupera el contenido de la TABLA1 y elimina la primera fila.


DECLARE cursor1 CURSOR SCROLL_LOCKS 
FOR
SELECT * FROM tabla1

OPEN cursor1
FETCH NEXT FROM cursor1

DELETE tabla1 WHERE CURRENT OF cursor1

CLOSE cursor1
DEALLOCATE cursor1
GO


