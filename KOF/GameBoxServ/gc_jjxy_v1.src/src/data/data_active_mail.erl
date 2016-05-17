-module(data_active_mail).
-include("../include/comm.hrl").

-export([get/1]).

% get(成长类型,等级);
% 活动奖励邮件内容配置表;
% 
get(1001)->
	["  你在 帮派BOSS 活动中造成了 ~p 点伤害 \n  伤害排名为: ~p，获得帮派贡献 + ~p 点，美刀 +~p",4];
get(1002)->
	["  你在 世界BOSS 活动中造成了 ~p 点伤害，获得奖励：美刀 +~p  \n伤害排名为: ~p，获得以下奖励",3];
get(1003)->
	["  你成功击杀了BOSS，霸气测漏，获得奖励：美刀 + ~p",1];
get(1004)->
	["  恭喜你在跨服竞技活动中获得了第 ~p 名奖励，所得奖励见邮件附件所示。\n                 感谢你对 《五指西游》 的支持，祝你游戏愉快！",1];
get(1005)->
	["  恭喜你在跨服竞技活动中勇夺桂冠，所得奖励见邮件附件所示。\n                 感谢你对 《五指西游》 的支持，祝你游戏愉快！",0];
get(_)->?null.