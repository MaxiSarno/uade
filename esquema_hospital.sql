/*TP1: Creación de la BD, Logins y Usuarios.*/

CREATE DATABASE db1606n12 ON PRIMARY
(NAME='db1606n12.dat', SIZE= 5MB, MAXSIZE=20MB, FILEGROWTH=1MB)
LOG ON (NAME='db1606n12.log',
SIZE=2MB, MAXSIZE=5MB, FILEGROWTH=1MB)

CREATE LOGIN db1606n12 WITH PASSWORD='123456',    		
DEFAULT_DATABASE=db1606n12,   	
CHECK_EXPIRATION=OFF,
CHECK_POLICY=OFF   		

CREATE LOGIN db1606n12r WITH PASSWORD='123456',    		
DEFAULT_DATABASE=db1606n12,   	
CHECK_EXPIRATION=OFF,   	
CHECK_POLICY=OFF   		

CREATE LOGIN db1606n12w WITH PASSWORD='123456',    		
DEFAULT_DATABASE=db1606n12,   	
CHECK_EXPIRATION=OFF,   	
CHECK_POLICY=OFF

/* Posicionado sobre la base de datos a transferir */
use db1606n12
go
sp_changedbowner 'db1606n12'

/* Conectarse como DBO */
CREATE USER dbr FOR LOGIN db1606n12r WITH DEFAULT_SCHEMA=DBO
CREATE USER dbw FOR LOGIN db1606n12w WITH DEFAULT_SCHEMA=DBO   	
sp_addrolemember db_datareader, dbr
sp_addrolemember db_datawriter, dbw

CREATE TABLE Integrantes(
nroLibreta int NOT NULL,
nombre varchar(30) NOT NULL,
apellido varchar(30) NOT NULL,
curso int NOT NULL,
nroGrupo int NOT NULL,
CONSTRAINT PK_Integrantes PRIMARY KEY CLUSTERED (nroLibreta)
)

﻿/* Definicion del Tipos de Datos */

exec sp_addtype 'tipo_sigla', 'varchar(8)', 'not null'

exec sp_addtype 'tipo_dni', 'varchar(8)', 'not null'

exec sp_addtype 'tipo_id', 'smallint', 'not null'


 /* Definicion de las Reglas de Dominio */
 
CREATE RULE sigla_rule AS @sigla not like '%[0-9]%'
GO
 
CREATE RULE dni_rule AS @dni like '%[0-9]%'
GO
 
CREATE RULE estado_rule AS @valor = 'verdadero' or @valor = 'falso'
GO
 
 
/* Creación de las tablas */
 
create table medicos
(       	
   matricula tipo_id not null,
   nombre char(20) not null,
   apellido char(20) not null,
   activo char (10) not null,                         	
   sexo char(1) not null,
   constraint pk_medicos primary key(matricula),
   constraint check_medicos_sexo Check (LOWER(sexo) = 'm' or LOWER(sexo) = 'f')
)
 
exec sp_bindrule 'estado_rule', 'medicos.activo'
 
 create table especialidades
(       	
   idespecialidad tipo_id,
   especialidad char(20) not null,
   constraint pk_especialidad primary key(idespecialidad)
)

create table especialidades_medicos
(       	
   matricula tipo_id not null,
   idespecialidad tipo_id,
   constraint pk_especialidades_medicos primary key (matricula,idespecialidad)
)
 
 
create table estudios
(       	
   idestudio tipo_id,
   estudio char(20) not null,
   activo char(10) not null,                          	
   constraint pk_estudios primary key (idestudio)
)
 
exec sp_bindrule 'estado_rule', 'estudios.activo'
 
 
create table estudios_especialidades
(       	
   idestudio tipo_id,
   idespecialidad tipo_id,
   constraint pk_estudios_especialidades primary key(idestudio,idespecialidad)
)
 
 
create table institutos
(       	
   idinstituto tipo_id,
   instituto char(20) not null,
   activo char(10) not null,
   constraint pk_institutos primary key(idinstituto)
)
  
exec sp_bindrule 'estado_rule', 'institutos.activo'


create table obrassociales
(       	
   sigla tipo_sigla,
   nombre char(20) not null,
   categoria char(2) not null,
   constraint pk_obrassociales primary key(sigla),
   constraint check_os_categoria Check (LOWER(categoria) = 'os' or LOWER(categoria) = 'pp')
)
 
exec sp_bindrule 'sigla_rule', 'obrassociales.sigla'
 
 
create table planes
(       	
   sigla tipo_sigla,
   nroplan int not null,
   nombre char (20) not null,
   activo char (10) not null,
   constraint pk_planes primary key(sigla,nroplan),
   constraint check_planes_nroplan Check (nroplan >= 0 and nroplan <= 12)
)
 
exec sp_bindrule 'sigla_rule', 'planes.sigla'
exec sp_bindrule 'estado_rule', 'planes.activo'
 
 
create table coberturas
(       	
   sigla tipo_sigla,
   nroplan int not null,
   idestudio tipo_id,
   cobertura float not null,
   constraint pk_coberturas primary key(sigla,nroplan,idestudio),
   constraint check_coberturas_porcentaje Check (cobertura >=0 and cobertura <=1 )
)
 
exec sp_bindrule 'sigla_rule', 'coberturas.sigla'
 
 
create table afiliados
(       	
   dni tipo_dni,
   sigla tipo_sigla,
   nroplan int not null,
   nroafiliado int not null,
   constraint pk_afiliados primary key(sigla,dni,nroplan)
)
 
exec sp_bindrule 'sigla_rule', 'afiliados.sigla'
exec sp_bindrule 'dni_rule', 'afiliados.dni'
  
 
create table pacientes
(       	
   dni tipo_dni,
   nombre char(20) not null,
   apellido char(20) not null,
   sexo char(1) not null,
   nacimiento datetime not null, /* Las fechas se deben insertar 'YYYYMMDD' */
   constraint pk_pacientes primary key(dni),
   constraint check_pacientes_nacimiento Check (nacimiento between DATEADD(yy,-80, getdate()) and DATEADD(yy,-21, getdate())),
   constraint check_pacientes_sexo Check (LOWER(sexo) = 'm' or LOWER(sexo) = 'f')
)
 
exec sp_bindrule 'dni_rule', 'pacientes.dni'
 
 
create table precios
(       	
   idestudio tipo_id,
   idinstituto tipo_id,
   precio float not null,
   constraint pk_precios primary key(idestudio,idinstituto),
   constraint check_precios_precio Check (precio <= 5000 and precio >=0 )
)
 
 
create table historias
(       	
   dni tipo_dni,
   idestudio tipo_id,
   idinstituto tipo_id,
   fecha datetime not null,
   matricula tipo_id not null,
   sigla tipo_sigla,
   pagado char(1) not null,
   observaciones char (100),
   constraint pk_historias primary key(idestudio,fecha,dni),
   constraint check_historias_pagado Check (LOWER(pagado) = 'v' or LOWER(pagado) = 'f'),
   constraint check_historias_fecha Check (([fecha]>=dateadd(month,(-1),getdate()) AND [fecha]<=dateadd(month,(1),getdate())))
 
)

exec sp_bindrule 'dni_rule', 'historias.dni'
exec sp_bindrule 'sigla_rule', 'historias.sigla'
 
/* Definición de claves foráneas */
alter table especialidades_medicos
Add constraint espe_fk1_medi foreign key (matricula) references medicos,
constraint espe_fk2_medi foreign key (idespecialidad) references especialidades
 
alter table estudios_especialidades
Add constraint estu_fk1_espe foreign key (idestudio) references estudios,
constraint estu_fk2_espe foreign key (idespecialidad) references especialidades
 
alter table planes
Add constraint planes_fk_os foreign key (sigla) references obrassociales
 
alter table coberturas
Add constraint cobe_fk_planes foreign key (sigla,nroplan) references planes,
constraint cobe_fk_estu foreign key (idestudio) references estudios
 
alter table afiliados
Add constraint afil_fk_paci foreign key (dni) references pacientes,
constraint afil_fk_planes foreign key (sigla,nroplan) references planes
 
alter table precios
Add constraint precios_fk_estu foreign key(idestudio) references estudios,
constraint precios_fk_insti foreign key (idinstituto) references institutos
 
alter table historias
Add constraint histo_fk_estu foreign key(idestudio) references estudios,
constraint histo_fk_insti foreign key(idinstituto) references institutos,
constraint histo_fk_medi foreign key(matricula) references medicos,
constraint histo_fk_paci foreign key(dni) references pacientes,
constraint histo_fk_os foreign key(sigla) references obrassociales
 

/* Insercion de datos */
 
insert into medicos values (01,'MEDICO_NOMBRE_01','MEDICO_APELLIDO_01','verdadero','m')
 
insert into medicos values (02,'MEDICO_NOMBRE_02','MEDICO_APELLIDO_02','verdadero','m')
 
insert into medicos values (03,'MEDICO_NOMBRE_03','MEDICO_APELLIDO_03','verdadero','m')
 
insert into medicos values (04,'MEDICO_NOMBRE_04','MEDICO_APELLIDO_04','verdadero','m')
 
insert into medicos values (05,'MEDICO_NOMBRE_05','MEDICO_APELLIDO_05','falso','m')
 
insert into medicos values (06,'MEDICO_NOMBRE_06','MEDICO_APELLIDO_06','falso','m')
 
insert into medicos values (07,'MEDICO_NOMBRE_07','MEDICO_APELLIDO_07','verdadero','f')
 
insert into medicos values (08,'MEDICO_NOMBRE_08','MEDICO_APELLIDO_08','verdadero','f')
 
insert into medicos values (09,'MEDICO_NOMBRE_09','MEDICO_APELLIDO_09','verdadero','f')
 
insert into medicos values  (10,'MEDICO_NOMBRE_10','MEDICO_APELLIDO_10','falso','f')
  
 
insert into especialidades values (01,'ESPECIALIDAD_01')
insert into especialidades values (02,'ESPECIALIDAD_02')
insert into especialidades values (03,'ESPECIALIDAD_03')
insert into especialidades values (04,'ESPECIALIDAD_04')
insert into especialidades values (05,'ESPECIALIDAD_05')
insert into especialidades values (06,'ESPECIALIDAD_06')
insert into especialidades values (07,'ESPECIALIDAD_07')
insert into especialidades values (08,'ESPECIALIDAD_08')
insert into especialidades values (09,'ESPECIALIDAD_09')
insert into especialidades values (10,'ESPECIALIDAD_10')
 
 
insert into especialidades_medicos values (001,01)
insert into especialidades_medicos values (001,02)
insert into especialidades_medicos values (001,03)
insert into especialidades_medicos values (002,02)
insert into especialidades_medicos values (002,10)
insert into especialidades_medicos values (003,03)
insert into especialidades_medicos values (004,04)
insert into especialidades_medicos values (005,05)
insert into especialidades_medicos values (006,06)
insert into especialidades_medicos values (007,07)
insert into especialidades_medicos values (008,08)
insert into especialidades_medicos values (009,09)
insert into especialidades_medicos values (010,05)
 

insert into estudios values (01,'ESTUDIO_01','falso')
insert into estudios values (02,'ESTUDIO_02','verdadero')
insert into estudios values (03,'ESTUDIO_03','falso')
insert into estudios values (04,'ESTUDIO_04','verdadero')
insert into estudios values (05,'ESTUDIO_05','falso')
insert into estudios values (06,'ESTUDIO_06','verdadero')
insert into estudios values (07,'ESTUDIO_07','falso')
insert into estudios values (08,'ESTUDIO_08','verdadero')
insert into estudios values (09,'ESTUDIO_09','falso')
insert into estudios values (10,'ESTUDIO_10','verdadero')

 
insert into estudios_especialidades values (01,01)
insert into estudios_especialidades values (02,02)
insert into estudios_especialidades values (03,03)
insert into estudios_especialidades values (04,04)
insert into estudios_especialidades values (05,05)
insert into estudios_especialidades values (06,06)
insert into estudios_especialidades values (07,07)
insert into estudios_especialidades values (08,08)
insert into estudios_especialidades values (09,09)
insert into estudios_especialidades values (10,10)
 
 
insert into institutos values (01,'INSTITUTO_01','falso')
insert into institutos values (02,'INSTITUTO_02','verdadero')
insert into institutos values (03,'INSTITUTO_03','falso')
insert into institutos values (04,'INSTITUTO_04','verdadero')
insert into institutos values (05,'INSTITUTO_05','falso')
insert into institutos values (06,'INSTITUTO_06','verdadero')
insert into institutos values (07,'INSTITUTO_07','falso')
insert into institutos values (08,'INSTITUTO_08','verdadero')
insert into institutos values (09,'INSTITUTO_09','falso')
insert into institutos values (10,'INSTITUTO_10','verdadero')
 

insert into precios values (01,01,10.50)
insert into precios values (02,02,20.48)
insert into precios values (03,03,30.90)
insert into precios values (04,04,40.35)
insert into precios values (05,05,50.90)
insert into precios values (06,06,60.35)
insert into precios values (07,07,70.90)
insert into precios values (08,08,80.85)
insert into precios values (09,09,90.10)
insert into precios values (10,10,100.90)
 

insert into pacientes values ('00000001',
'PACIENTE_NOMBRE_01','PACIENTE_APELLIDO_01','m','1970-05-11 00:00:00')
 
insert into pacientes values ('00000002',
'PACIENTE_NOMBRE_02','PACIENTE_APELLIDO_02','m','1971-06-12 00:00:00')
 
insert into pacientes values ('00000003',
'PACIENTE_NOMBRE_03','PACIENTE_APELLIDO_03','f','1972-03-10 00:00:00')
 
insert into pacientes values ('00000004',
'PACIENTE_NOMBRE_04','PACIENTE_APELLIDO_04','f','1973-01-01 00:00:00')
 
insert into pacientes values ('00000005',
'PACIENTE_NOMBRE_05','PACIENTE_APELLIDO_05','m','1974-01-11 00:00:00')
 
insert into pacientes values ('00000006',
'PACIENTE_NOMBRE_06','PACIENTE_APELLIDO_06','m','1975-09-06 00:00:00')
 
insert into pacientes values ('00000007',
'PACIENTE_NOMBRE_07','PACIENTE_APELLIDO_07','f','1976-12-01 00:00:00')
 
insert into pacientes values ('00000008',
'PACIENTE_NOMBRE_08','PACIENTE_APELLIDO_08','m','1977-11-01 00:00:00')
 
insert into pacientes values ('00000009',
'PACIENTE_NOMBRE_09','PACIENTE_APELLIDO_09','f','1981-05-09 00:00:00')
 
insert into pacientes values ('00000010',
'PACIENTE_NOMBRE_10','PACIENTE_APELLIDO_10','m','1979-01-05 00:00:00')
 

insert into obrassociales values ('OSDE','OOSS_01','OS')
insert into obrassociales values ('OSECAC','OOSS_02','PP')
insert into obrassociales values ('GALENO','OOSS_03','OS')
insert into obrassociales values ('PASTEUR','OOSS_04','PP')
insert into obrassociales values ('PJ','OOSS_05','OS')
insert into obrassociales values ('SWISS','OOSS_06','PP')
insert into obrassociales values ('CENCO','OOSS_07','OS')
insert into obrassociales values ('OSTAM','OOSS_08','PP')
insert into obrassociales values ('NAVALES','OOSS_09','OS')
insert into obrassociales values ('UOCRA','OOSS_10','PP')
 
insert into planes values ('OSDE',01,'PLAN_01','falso')
insert into planes values ('OSECAC',02,'PLAN_02','verdadero')
insert into planes values ('GALENO',03,'PLAN_03','falso')
insert into planes values ('PASTEUR',04,'PLAN_04','verdadero')
insert into planes values ('PJ',05,'PLAN_05','falso')
insert into planes values ('SWISS',06,'PLAN_06','verdadero')
insert into planes values ('CENCO',07,'PLAN_07','falso')
insert into planes values ('OSTAM',08,'PLAN_08','verdadero')
insert into planes values ('NAVALES',09,'PLAN_09','falso')
insert into planes values ('UOCRA',10,'PLAN_10','verdadero')
 

insert into afiliados values ('00000001','OSDE'   ,01,01)
insert into afiliados values ('00000002','OSECAC' ,02,02)
insert into afiliados values ('00000003','GALENO' ,03,03)
insert into afiliados values ('00000004','PASTEUR',04,04)
insert into afiliados values ('00000005','PJ' 	   ,05,05)
insert into afiliados values ('00000006','SWISS'  ,06,06)
insert into afiliados values ('00000007','CENCO'  ,07,07)
insert into afiliados values ('00000008','OSTAM'  ,08,08)
insert into afiliados values ('00000009','NAVALES',09,09)
insert into afiliados values ('00000010','UOCRA'  ,10,10)


insert into historias values ('00000001',01,01,GETDATE(),01,'OSDE','f','diag')
insert into historias values ('00000002',02,02,GETDATE(),02,'OSECAC','v','diag')
insert into historias values ('00000003',03,03,GETDATE(),03,'GALENO','f','diag')
insert into historias values ('00000004',04,04,GETDATE(),04,'PASTEUR','v','diag')
insert into historias values ('00000005',05,05,GETDATE(),05,'PJ','f','diag')
insert into historias values ('00000006',06,06,GETDATE(),06,'SWISS','v','diag')
insert into historias values ('00000007',07,07,GETDATE(),07,'CENCO','f','diag')
insert into historias values ('00000008',08,08,GETDATE(),08,'OSTAM','v','diag')
insert into historias values ('00000009',09,09,GETDATE(),09,'NAVALES','f','diag')
insert into historias values ('00000010',10,10,GETDATE(),10,'UOCRA','v','diag')

 
insert into coberturas values ('OSDE',   01,01,0.3)
insert into coberturas values ('OSECAC', 02,02,0.3)
insert into coberturas values ('GALENO', 03,03,0.4)
insert into coberturas values ('PASTEUR',04,04,0.4)
insert into coberturas values ('PJ', 	05,05,0.4)
insert into coberturas values ('SWISS',  06,06,0.5)
insert into coberturas values ('CENCO',  07,07,0.5)
insert into coberturas values ('OSTAM',  08,08,0.5)
insert into coberturas values ('NAVALES',09,09,0.7)
insert into coberturas values ('UOCRA',  10,10,0.7)
