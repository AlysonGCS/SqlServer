create procedure SP_ClonarGrupoDePermissao(@UsuarioReferencia varchar(20), @UsuarioNovo varchar(20))
as
begin
insert into grupos_usuarios (grupo, USUARIO) select grupo,'TESTEALY' from GRUPOS_USUARIOS 
											where usuario = 'ALYSONG' AND GRUPO NOT IN 
											(SELECT GRUPO FROM GRUPOS_USUARIOS WHERE USUARIO = 'TESTEALY')
end

drop procedure SP_ClonarGrupoDePermissao

Exec SP_ClonarGrupoDePermissao 'ALYSONG', 'TESTEALY' -- usuario referencia, usuario novo


