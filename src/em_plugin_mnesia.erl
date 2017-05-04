%%%-------------------------------------------------------------------
%%% @author truonglx
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. Apr 2017 12:27
%%%-------------------------------------------------------------------
-module(em_plugin_mnesia).
-author("truonglx").
-include("emq_acl_topic.hrl").
%% API
-export([check_user/2,read_list_id/1, insert/3, mnesia_acl_count/0]).

check_user(ClientId, Topic) ->
  [Id | _] = binary:split(Topic, <<"/">>, [global]),
  io:fwrite("Id: ~p~n", [Id]),
  if
    Id =:= ClientId -> allow;
    true -> deny
  end.
read_list_id(GroupID) ->
  [CL || #?AUTH_ACL_TAB{list_client_id = CL} <- mnesia:dirty_read(?AUTH_ACL_TAB, GroupID)].

insert(Id, GroupName, ListUserId) ->
  Fun = fun() ->
    mnesia:write(
      #?AUTH_ACL_TAB{group_id = (Id),
        group_name = (GroupName), list_client_id = (ListUserId)})
        end,
  mnesia:transaction(Fun).

-spec(mnesia_acl_count() -> non_neg_integer()).
mnesia_acl_count() -> mnesia:table_info(?AUTH_ACL_TAB, size).
