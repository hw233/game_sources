%%% -------------------------------------------------------------------
%%% Author  : tanwer
%%% Description : clan_srv
%%%
%%% Created : 2012-11-15
%%% -------------------------------------------------------------------
-module(clan_srv).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("../include/comm.hrl").
%% --------------------------------------------------------------------
%% 调用导出
-export([
		 join_clan_cast/2,
		 cancel_clan_cast/2,
		 devote_add_cast/4,
		 request_audit_cast/4,
		 
		 open_active_cast/1,
		 cat_hudong_cast/4,
		 boss_harm_updata_cast/3

		 ]).
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
		_ 		-> ?MSG_ERROR("Terminate Reason:~w State:~w ",[Reason,State])
	end.
code_change(_OldVsn, State, _Extra) -> {?ok, State}.
%% --------------------------------------------------------------------
%%% DO 内部处理
%% --------------------------------------------------------------------

%% 状态定义
-record(state, {}).


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
	State = #state{},
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

do_cast({join_clan_cast,{Player,ClanId}}, State) ->
	clan_mod:join_clan_handl(Player,ClanId),
	{?noreply,State};

do_cast({cancel_clan_cast,{Uid,ClanId}}, State) ->
	clan_mod:cancel_clan_handl(Uid, ClanId),
	{?noreply,State};

do_cast({request_audit_cast,{{Name,NameColor}, Uid, ToUid, State0}}, State) ->
	clan_mod:request_audit_handl({Name,NameColor}, Uid, ToUid, State0),
	{?noreply,State};

do_cast({devote_add_cast,{LogSrc,Uid,Clan,Value}}, State) ->
	clan_api:devote_add_handl(LogSrc,Uid,Clan,Value),
	{?noreply,State};

do_cast({cat_hudong_cast,{Log,Uid,ClanId,AddExp}}, State) ->
	clan_active_api:cat_hudong_handl(Log,Uid,ClanId,AddExp),
	{?noreply,State};

do_cast({open_active_cast,{MPid}}, State) ->
	clan_boss_api:open_active_handl(MPid),
	{?noreply,State};

do_cast({boss_harm_updata_cast,{{Uid,Lv,Name,NameColor},WarB,Spid}}, State) ->
	clan_boss_api:boss_harm_updata_handl({Uid,Lv,Name,NameColor},WarB,Spid),
	{?noreply,State};


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
%% do_info(Info,State)->     %% 示列
%% 	{?noreply,State};
do_info({?inet_reply,_Socket,_Msg}, State) -> %% 向Socket发包 返回
	{?noreply, State};
do_info({?exec, Mod, Fun, Arg},State)->
	State2 = Mod:Fun(State, Arg),
	{?noreply, State2 };
do_info(?doloop,State)->  %% 处理注册定时 doloop
	{?noreply,State};
do_info(Info,State)-> %% 默认处理(勿删)
	?MSG_ERROR("Info Info:~w State:~w", [Info,State]),
	{?noreply,State}.


%% --------------------------------------------------------------------
%% Function: do_terminate/2
%% Description: 退出处理内容
%% --------------------------------------------------------------------
do_terminate(_State)-> 
	?ok.


%% --------------------------------------------------------------------
%%% 外部调用Serv
%% --------------------------------------------------------------------
%% Call 例子
%% request_call(Request) ->
%% 	gen_server:call(?MODULE, {request,Request}). % 单Serv
%% 	app_link:call(?MODULE, {request,Request}).   % 多核 多Serv 


%% Cast 例子
%% msg_cast(Msg)->
%% 	gen_server:cast(?MODULE, {msg,Hearsay}).     % 单Serv 
%% 	app_link:cast(?MODULE, {msg,Hearsay}).	     % 多核 多Serv

%% 申请加入帮派
join_clan_cast(Player,ClanId) ->
	gen_server:cast(?MODULE, {join_clan_cast,{Player,ClanId}}).

cancel_clan_cast(Uid,ClanId) ->
	gen_server:cast(?MODULE, {cancel_clan_cast,{Uid,ClanId}}).

request_audit_cast({Name,NameColor}, Uid, ToUid, State0) ->
	gen_server:cast(?MODULE, {request_audit_cast,{{Name,NameColor}, Uid, ToUid, State0}}).

devote_add_cast(LogSrc,Uid,Clan,Value) ->
	gen_server:cast(?MODULE, {devote_add_cast,{LogSrc,Uid,Clan,Value}}).

cat_hudong_cast(Log,Uid,ClanId,AddExp) -> 
	gen_server:cast(?MODULE, {cat_hudong_cast,{Log,Uid,ClanId,AddExp}}).
	
	
open_active_cast(MPid) ->
	gen_server:cast(?MODULE, {open_active_cast,{MPid}}).

boss_harm_updata_cast({Uid,Lv,Name,NameColor},WarB,Spid) ->
	gen_server:cast(?MODULE, {boss_harm_updata_cast,{{Uid,Lv,Name,NameColor},WarB,Spid}}).
	
	
	



