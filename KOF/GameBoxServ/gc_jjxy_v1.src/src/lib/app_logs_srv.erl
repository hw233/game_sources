%%% -------------------------------------------------------------------
%%% Author  : 一平|dreamxyp@gmail.com
%%% Description : 错误日志
%%%
%%% Created : 2012-11-15
%%% -------------------------------------------------------------------
-module(app_logs_srv).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("../include/comm.hrl").
%% --------------------------------------------------------------------
%% 调用导出
-export([error_cast/4,reopen_cast/0]).
%% --------------------------------------------------------------------
%% 以下系统默认导出(勿删)
-export([start_link/2,init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]).
%% 以下系统默认函数(勿删)
start_link(SrvName,Cores) ->
	app_link:gen_server_start_link(SrvName, ?MODULE, [Cores], Cores).
init([Cores])     ->
	process_flag(?trap_exit, ?true),
	Reply = do_init(Cores),
	?MSG_PRINT(" Server Start Cores:~p OnCore:~p",[Cores, util:core_idx() ]),
	Reply.
handle_call(Request, From, State) -> 
	?TRY_DO(do_call(Request,From,State) ).
handle_cast(Msg,  State) -> 
	?TRY_DO(do_cast(Msg,State) ).
handle_info(Info, State) -> 
	?TRY_DO(do_info(Info,State)).
terminate(Reason,State)  -> 
	?TRY_DO(do_terminate(State)),
	case Reason of
		?normal -> ?skip;
		_ 		-> ?skip % ?MSG_ERROR("Terminate Reason:~w State:~w ",[Reason,State])
	end.
code_change(_OldVsn, State, _Extra) -> {?ok, State}.
%% --------------------------------------------------------------------
%%% DO 内部处理
%% --------------------------------------------------------------------

%% 状态定义
-record(state, {fh=0}).


%% --------------------------------------------------------------------
%% Function: do_init/1
%% Description: 初始化状态
%% Returns: {?ok, State}          |
%%          {?ok, State, Timeout} |
%%          ?ignore               |
%%          {?stop, Reason}
%% --------------------------------------------------------------------
do_init(_Args) ->
	%% 初始化State
	FH    = app_tool:error_fileop(),
	State = #state{fh=FH},
	%% 注册定时 doloop
	%% crond_api:reg(self(), MilliSecond), 
	{?ok, State}.





%% --------------------------------------------------------------------
%% Function: do_call/3
%% Description: 等待Call处理
%% Returns: {?reply, Reply, State}          |
%%          {?reply, Reply, State, Timeout} |
%%          {?noreply, State}               |
%%          {?noreply, State, Timeout}      |
%%          {?stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {?stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
%% do_call(Request,From,State)-> %% 示列
%% 	{?reply,?ok,State};
do_call(Request,From,State)->    %% 默认处理(勿删)
	?MSG_ERROR("Call Request:~p From:~w State:~w", [Request, From, State]),
	{?reply,?ok,State}.





%% --------------------------------------------------------------------
%% Function: do_cast/2
%% Description: 异步Cast处理
%% Returns: {?noreply, State}          |
%%          {?noreply, State, Timeout} |
%%          {?stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
%% do_cast(Msg,State) ->  %% 示列
%% 	{?noreply,State};
do_cast({error,Msg,Data,Module,Line}, #state{fh=H}=State)->     % 错误日志
	case ?DEBUG_LEVEL_ERROR of 
		-1 -> ?ok;
		_  -> app_tool:error_filewrite(Msg,Data,Module,Line,H)
	end,
	{?noreply,State};
do_cast(reopen,#state{fh=H}=State)->    % 时期关开文件
	file:close(H),
	H2 = app_tool:error_fileop(),
	{?noreply,State#state{fh=H2}};
do_cast(Msg,State)->      %% 默认处理(勿删)
	?MSG_ERROR("Cast Msg:~w State:~w", [Msg,State]),
	{?noreply,State}.


%% --------------------------------------------------------------------
%% Function: do_info/2
%% Description: 异步Info处理
%% Returns: {?noreply, State}          |
%%          {?noreply, State, Timeout} |
%%          {?stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
do_info({?inet_reply,_Socket,_Msg}, State) -> %% 向Socket发包 返回
	{?noreply, State};
do_info({?exec, Mod, Fun, Arg},State)->
	State2 = Mod:Fun(State, Arg),
	{?noreply, State2 };
%% do_info(?doloop,State)->  %% 处理注册定时 doloop
%% 	{?noreply,State};
do_info(Info,State)-> %% 默认处理(勿删)
	?MSG_ERROR("Info Info:~w State:~w", [Info,State]),
	{?noreply,State}.


%% --------------------------------------------------------------------
%% Function: do_terminate/2
%% Description: 退出处理内容
%% --------------------------------------------------------------------
do_terminate(#state{fh=H})->
	file:close(H),
	?ok.


%% --------------------------------------------------------------------
%%% 外部调用Serv
%% --------------------------------------------------------------------
%% Call 例子
%% request_call(Request) ->
%% 	gen_server:call(?MODULE, {request,Request}). % 单Serv
%% 	app_link:call(?MODULE, {request,Request}).   % 多核 多Serv 


%% 错误日志
error_cast(Msg,Data,Module,Line)->
	case whereis(?MODULE) of
		Pid when is_pid(Pid) andalso Pid /= self() ->
 			gen_server:cast(Pid, {error,Msg,Data,Module,Line});     % 错误日志
		_ ->
			app_tool:error(Msg,Data,Module,Line)
	end.
%% 	app_link:cast(?MODULE, {msg,Hearsay}).	     % 多核 多Serv


%% 定时重起文件
reopen_cast()->
 	gen_server:cast(?MODULE, reopen).     % 时期关开文件
