@@error = 0 	Si se completa con éxito la ejecución de la sentencia SQL. INSERT y DELETE
@@error <> 0 	Si se produce un error en la sentencia, devuelve el número del mensaje de error. INSERT y DELETE

@@ROWCOUNT
Devuelve el número de filas afectadas por la última instrucción. IF @@ROWCOUNT...

@@TRANCOUNT
Devuelve el número de transacciones activas en la conexión actual.
@@trancount = 0 	Cuando se ejecuta una instrucción ROLLBACK deja a @@trancount en 0
@@trancount += 1 	Cuando se ejecuta una instrucción BEGIN TRAN se incrementa en 1 el valor de @@trancount.
@@trancount -= 1 	Cuando se ejecuta una instrucción COMMIT se decrementa en 1 el valor de @@trancount.
@@trancount s/m 	Cuando se ejecuta una instrucción ROLLBACK SAVEPOINT no afecta al valor de @@trancount.
Se utiliza @@TRANCOUNT para comprobar si hay transacciones abiertas que haya que confirmar.

XACT_STATE
Devuelve el estado de la transacción activa en la conexión actual.
XACT_STATE = 1 	La sesión tiene una transacción activa. Puede realizar cualquier acción, incluida la escritura de datos y la confirmación de la transacción.
XACT_STATE = 0 	No hay ninguna transacción activa para la sesión.
XACT_STATE = -1 	La sesión tiene una transacción activa, pero se ha producido un error por el cual la transacción se clasificó como no confirmable. 

BEGIN TRY
    BEGIN TRANSACTION;
        ALTER TABLE my_books DROP COLUMN author;
    	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() as ErrorNumber,
        ERROR_MESSAGE() as ErrorMessage;

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
 END CATCH;
GO




BEGIN TRANSACTION modificaderechos

SAVE TRANSACTION cambiaporcentaje

ROLLBACK TRANSACTION cambiaporcentaje
COMMIT TRANSACTION modificaderechos
