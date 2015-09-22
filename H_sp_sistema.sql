sp_addlogin 	[ @loginame = ] 'login' [ , [ @passwd = ] 'password' ] [ , [ @defdb = ] 'database' ]
sp_addlogin 'abd', 'abd'

sp_defaultdb 	[ @loginame = ] 'login' ,[ @defdb = ] 'database'
sp_defaultdb 'abd', 'jugadores'

sp_droplogin 	[ @loginame = ] 'login'
sp_droplogin 'abd'

sp_helplogins 	[[ @loginame = ] 'login']abd/dbgrupos/dbo/abd/master/abd
sp_helplogins 'abd'

sp_password 	[ [ @old = ] 'old_password' , ] [ @new =] 'new_password' [ , [ @loginame = ] 'login' ] i>
sp_password 'abd', 'abd04'
 

sp_addsrvrolemember 	[ @loginame = ] 'login',[ @srvrolename = ] 'role'
sp_addsrvrolemember 'abd', 'sysadmin'

sp_dropsrvrolemember 	[ @loginame = ] 'login', [ @srvrolename = ] 'role'
sp_dropsrvrolemember 'abd', 'sysadmin'

sp_helpsrvrole 	[[ @srvrolename = ] 'role']
sp_helpsrvrole
 
sysadmin	Administradores del sistema
securityadmin	Administradores de seguridad
serveradmin	Administradores de servidor
setupadmin	Administradores de instalación
processadmin	Administradores de proceso
diskadmin	Administradores de disco
dbcreator	Creadores de bases de datos

sp_helpsrvrolemember 	[[ @srvrolename = ] 'role']
sp_helpsrvrolemember 'sysadmin'
 
sysadmin	sa
sysadmin	abd


sp_addrole 	[ @rolename = ] 'role',[ @sownername = ] 'owner'
sp_addrole 'desarrolladores'

sp_addrolemember 	[ @rolename = ] 'role',[ @membername = ] 'user'
sp_addrolemember 'db_datareader', 'usuarioxx'

sp_changedbowner 	[ @loginame = ] 'login'
sp_changedbowner 'loginxx'
 
sp_droprole 	[ @rolename = ] 'role'
sp_droprole 'desarrolladores'

sp_droprolemember 	[ @rolename = ] 'role',[ @membername = ] 'user'
sp_droprolemember 'db_datareader', 'usuarioxx'
 
sp_grantdbaccess 	[ @loginname = ] 'login',[ [ @username = ] 'user' ]
sp_grantdbaccess 'loginxx', 'usuarioxx'

sp_helprole 	[[ @rolename = ] 'role']
sp_helprole
 
public 	db_owner	db_accessadmin
db_securityadmin 	db_ddladmin	db_backupoperator
db_datareader 	db_datawriter	db_denydatareader
db_denydatawirter	otros
Devuelve información acerca de las funciones de la base de datos actual.

sp_helprolemember 	[ [ @rolename = ] 'role' ]
sp_helprolemember 'db_owner'

sp_helpuser 	[ { [ @username = ] 'user' | [ @rolename = ] 'role' } ]
sp_helpuser 'dbo'

sp_revokedbaccess 	[ @username = ] 'user'
sp_revokedbaccess 'usuarioxx'


sp_addtype 	[ @typename = ] type,[ @phystype = ] system_data_type[ , [ @nulltype = ] 'null_type' ][ , [ @owner = ] 'owner_name' ]
sp_addtype 'tipoxx', 'char(10)', 'not null'

sp_bindrule 	[ @rulename = ] 'rule' ,[ @objname = ] 'object'
sp_bindrule 'rule_ssn', 'ssn'
sp_bindrule 'rule_tipo', 'personas.tipo'

sp_droptype 	[ @typename = ] type,
sp_droptype 'tipoxx'

sp_help 	[ [ @objectname = ] object ]
sp_help 'tipoxx'

sp_helpconstraint 	[ @tablename = ] name
sp_helpconstraint 'authors'

sp_helpdb 	[ [ @dbname = ] name ]
sp_helpdb 'pubs'

sp_helpdevice 	[ [ @devicename = ] name ]
sp_helpdevice

sp_helptext 	[ @objectname = ] name ]
use 'pubs'
sp_helptext 'byroyalty'

sp_rename 	[ @objname = ] oldname,[ @newname = ] newname[ [ @objtype = ] objtype ]@objtype = { column | database | index | object | userdatatype }
use 'pubs'
sp_rename 'custumers', 'clientes'
sp_rename 'clientes.[contact title]', 'titulos', 'column'

sp_renamedb 	[ @dbname = ] oldname,[ @newname = ] newname
sp_renamedb 'pubs', 'publicaciones'

sp_unbindrule 	[@objname =] 'object'
sp_unbindrule 'ssn'
sp_unbindrule 'personas.tipo'
