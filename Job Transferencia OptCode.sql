USE [msdb]
GO

/****** Object:  Job [JobTransf OPTCODE]    Script Date: 07/07/2023 17:15:30 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 07/07/2023 17:15:30 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'JobTransf OPTCODE', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'consultor.clairton', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Query]    Script Date: 07/07/2023 17:15:30 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Query', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON;  
  
DECLARE @sCodigoItem VARCHAR(50);
DECLARE @iNumeroOdf INT;
DECLARE @dQtdeMovimentacao DECIMAL(19,4);
DECLARE @iCodigoLocalOrigem INT;
DECLARE @iCodigoLocalDestino INT;
DECLARE @Mensagem VARCHAR(200);
  
DECLARE listarItensTransferencia CURSOR FOR   
SELECT top 10 ITEM AS sCodigoItem, ODF AS iNumeroOdf, APONTAR as dQtdeMovimentacao, LOCAL_ORIGEM AS iCodigoLocalOrigem, LOCAL_DESTINO as iCodigoLocalDestino, '''' as Mensagem
   FROM VIEW_CST_LISTA_CONSUMO_OPTCODE_JOB (NOLOCK) WHERE  APONTAR > 0.5  
	order by dQtdeMovimentacao, ITEM desc   
OPEN listarItensTransferencia  
  
FETCH NEXT FROM listarItensTransferencia  
INTO @sCodigoItem, @iNumeroOdf, @dQtdeMovimentacao, @iCodigoLocalOrigem, @iCodigoLocalDestino, @Mensagem
  
WHILE @@FETCH_STATUS = 0  
BEGIN
	print ''Movimentando Materiais Opticode '' + @sCodigoItem  
	Begin Try
	      Begin Tran
                   exec gerarFifoLoteOptCode @sCodigoItem, @dQtdeMovimentacao, @iNumeroOdf
          Commit Tran
    End Try
    Begin Catch
      Rollback Tran
 End Catch

FETCH NEXT FROM listarItensTransferencia  
INTO @sCodigoItem, @iNumeroOdf, @dQtdeMovimentacao, @iCodigoLocalOrigem, @iCodigoLocalDestino, @Mensagem
END  

CLOSE listarItensTransferencia;  
DEALLOCATE listarItensTransferencia

	
	', 
		@database_name=N'Kabel', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Diamente das 1:00 as 7:00', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220406, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=70000, 
		@schedule_uid=N'566bdd44-8bef-4be8-94cb-17aa85e4e335'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


