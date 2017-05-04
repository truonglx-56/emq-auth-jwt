%%%-------------------------------------------------------------------
%%% @author truonglx
%%% @copyright (C) 2017, <BKAV>
%%% @doc
%%%  Check token with claim: exp, nbf,iss,username
%%% @end
%%% Created : 24. Apr 2017 12:37
%%%-------------------------------------------------------------------
-module(verify_token).
-author("truonglx").
-define(JWT_EXP, <<"exp">>).
-define(JWT_NBF, <<"nbf">>).
-define(JWT_ISS, <<"iss">>).
-define(JWT_USER, <<"email">>).
-define(JWT_USER_ID, <<"uid">>).

%% API
-export([validate/4, bin_to_num/1]).

validate(TokenInfo, Issuser, Username, ClientId) ->
  validate(TokenInfo, Issuser, posix_time(calendar:universal_time()), Username, ClientId).

validate(TokenInfo, Issuser, NowSeconds, Username, ClientId) ->
  Expiration = get_value_in_map(?JWT_EXP, TokenInfo),
  NotBefore = get_value_in_map(?JWT_NBF, TokenInfo),
  Token_Iss = get_value_in_map(?JWT_ISS, TokenInfo),
  Email = get_value_in_map(?JWT_USER, TokenInfo),
  UserId = get_value_in_map(?JWT_USER_ID, TokenInfo),
  io:fwrite("TruongLX:validate: Token_iss= ~p~n,Issuser=~p~n", [Email, Username]),
%%    get_value_in_list("https://www.bkav.com", Issuser)]),

  if
    Token_Iss =/= undefined ->
      case get_value_in_list(Token_Iss, Issuser) of
        undefined -> throw(token_rejectd_issuser);
        _ -> ok
      end;
    true -> throw(token_rejectd_issuser)
  end,
  IdInteger = bin_to_num(ClientId),
  if
    (IdInteger =:= undefined) or (UserId =:= undefined) or (IdInteger /= UserId) -> throw(token_rejected_user_id);
    (Email =:= undefined) or (Email =/= Username) -> throw(token_rejected_username);
    (Expiration =:= undefined) or (Expiration =< NowSeconds) -> throw(token_rejected_exp);
    (NotBefore =:= undefined) or (NowSeconds < NotBefore) -> throw(token_rejected_nbf);
    true -> ok
  end.

get_value_in_map(Key, Map) ->
  get_value_in_map(Key, Map, undefined).

get_value_in_map(Key, Map, Default) ->
  case maps:is_key(Key, Map) of
    true ->
      maps:get(Key, Map);
    _ ->
      Default
  end.
posix_time({Date, Time}) ->
  PosixEpoch = {{1970, 1, 1}, {0, 0, 0}},
  calendar:datetime_to_gregorian_seconds({Date, Time}) - calendar:datetime_to_gregorian_seconds(PosixEpoch).
get_value_in_list(Key, List) ->
  get_value_in_list(Key, List, undefined).

get_value_in_list(Key, List, Default) ->
  case lists:keysearch(Key, 1, List) of
    {value, {Key, Value}} ->
      Value;
    false ->
      Default
  end.
bin_to_num(Bin) ->
  N = binary_to_list(Bin),
  case string:to_float(N) of
    {error, no_float} -> case catch list_to_integer(N) of
                           {_, _} -> undefined;
                           F -> F
                         end;
    {F, _Rest} -> F
  end.
