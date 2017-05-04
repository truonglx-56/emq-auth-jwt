%%%-------------------------------------------------------------------
%%% @author truonglx
%%% @copyright (C) 2017, <BKAV>
%%% @doc
%%%
%%% @end
%%% Created : 18. Apr 2017 13:13
%%%-------------------------------------------------------------------
-module(emq_acl_jwt).
-author("truonglx").

-behaviour(emqttd_acl_mod).
-include("emq_acl_topic.hrl").
-include_lib("emqttd/include/emqttd.hrl").


%% ACL Callbacks
-export([init/1, check_acl/2, reload_acl/1, description/0, check_user_in_group/2,
  topic/1, access/1, empty/1, b2l/1]).

-record(state, {acl_query, acl_nomatch}).



init([{AclQuery, AclNomatch}, Env]) ->

  Copies = case proplists:get_value(storage_type, Env, disc) of
             disc -> disc_copies;
             ram -> ram_copies
           end,
%%  mnesia:delete_table(?AUTH_ACL_TAB),
  ok = emqttd_mnesia:create_table(?AUTH_ACL_TAB,
    [{type, ordered_set},
      {Copies, [node()]},
      {attributes,
        record_info(fields, ?AUTH_ACL_TAB)},
      {storage_properties, [{ets, [compressed]},
        {dets, [{auto_save, 1000}]}]}]),

  ok = emqttd_mnesia:copy_table(?AUTH_ACL_TAB),

  case mnesia:table_info(?AUTH_ACL_TAB, storage_type) of
    Copies -> ok;
    _ -> mnesia:change_table_copy_type(?AUTH_ACL_TAB, node(), Copies)
  end,

  {ok, #state{acl_query = AclQuery, acl_nomatch = AclNomatch}}.

check_acl({#mqtt_client{username = <<$$, _/binary>>}, _PubSub, _Topic}, _State) ->
  io:fwrite("emq_acl_jwt:check_acl:ignore"),
  ignore;

check_acl({#mqtt_client{client_id = ClientID, username = Username}, publish, ?ACL_ALLOW_TOPIC}, _State) ->
  io:fwrite("emq_acl_jwt:check_acl:allow"),
  %% Allow publish topic group : tao, xoa, add mem
  if
    ClientID =/= undefined andalso Username =/= undefined -> allow;
    true -> deny
  end;
check_acl({_, subscribe, ?ACL_ALLOW_TOPIC}, _State) ->
  %% deny subscribe topic group : tao, xoa, add mem
  deny;
%% group
check_acl({#mqtt_client{client_id = ClientID}, _, Topic = <<$g, $_, _/binary>>}, _) ->
  ListId = em_plugin_mnesia:read_list_id(Topic),
  Id = verify_token:bin_to_num(ClientID),
  check_user_in_group(ListId, Id);
check_acl({#mqtt_client{client_id = ClientID, username = Username}, _, <<$o, $_, _/binary>>}, _State) ->
  if
    ClientID =/= undefined andalso Username =/= undefined -> allow;
    true -> deny
  end;

%%chat don
check_acl({Client, _, Topic}, _) ->
  io:fwrite("CHECK_USER: ~p~n", [catch em_plugin_mnesia:check_user(Client#mqtt_client.client_id, Topic)]),
  em_plugin_mnesia:check_user(Client#mqtt_client.client_id, Topic).

allow(1) -> allow;
allow(0) -> deny;
allow(<<"1">>) -> allow;
allow(<<"0">>) -> deny.

access(1) -> subscribe;
access(2) -> publish;
access(3) -> pubsub;
access(<<"1">>) -> subscribe;
access(<<"2">>) -> publish;
access(<<"3">>) -> pubsub.

topic(<<"eq ", Topic/binary>>) ->
  {eq, Topic};
topic(Topic) ->
  Topic.

reload_acl(_State) ->
  ok.

description() ->
  "ACL with Mnesia".

b2l(null) -> null;
b2l(B) -> binary_to_list(B).

empty(null) -> true;
empty("") -> true;
empty(<<>>) -> true;
empty(_) -> false.

check_user_in_group([], _) -> allow(0);
check_user_in_group([List], UserId) ->
  try lists:foreach(
    fun(V) ->
      case V == UserId of
        true -> throw(V);
        false -> allow(0)
      end
    end, List) of
    _ -> allow(0)
  catch
    throw:_ -> allow(1)
  end.
