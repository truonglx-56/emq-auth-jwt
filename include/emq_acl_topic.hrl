%%%-------------------------------------------------------------------
%%% @author truonglx
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. Apr 2017 11:08
%%%-------------------------------------------------------------------
-author("truonglx").
-define(ACL_ALLOW_TOPIC, <<"server/groupchat/command">>).
-define(AUTH_ACL_TAB, mqtt_auth_acl).

-record(?AUTH_ACL_TAB, {
  group_id :: binary(),
  group_name :: binary(),
  list_client_id :: list(integer())}).
%% cho phep 1-pub,2-sub,3-pubsub
%%  access :: 1 | 2 | 3,
%% quyen 1-add,2- delete, 3-remove ,4-adddelremove group
%%  permission :: integer() | undefined}).