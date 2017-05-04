%%%-------------------------------------------------------------------
%%% @author truonglx
%%% @copyright (C) 2017, <BKAV>
%%% @doc
%%%
%%% @end
%%% Created : 18. Apr 2017 13:15
%%%-------------------------------------------------------------------
-module(emq_auth_jwt).
-author("truonglx").
-behaviour(emqttd_auth_mod).

-include("emq_auth_jwt.hrl").

-include_lib("emqttd/include/emqttd.hrl").

-import(emq_auth_jwt_cli, [is_superuser/2]).

-export([init/1, check/3, description/0]).

-record(key, {rsakey, algorithm, issuser}).

-define(EMPTY(Username), (Username =:= undefined orelse Username =:= <<>>)).

init({Pubkey, Algorithm, Iss}) ->
%%  io:fwrite("TruongLX:emq_auth_mysql:init: ~p~n", [{Pubkey}]),
  {ok, #key{rsakey = Pubkey, algorithm = Algorithm, issuser = Iss}}.

check(#mqtt_client{username = Username}, Password, _State) when ?EMPTY(Username); ?EMPTY(Password) ->
%%  io:fwrite("TruongLX:emq_auth_jwt_check:init: ~p~n", [{Username, Password, _State}]),
  {error, username_or_password_undefined};

check(Client, Password, State) ->
%%  io:fwrite("TruongLX:emq_auth_mysql:check: ~p~n", [{Password, Client, State}]),
  check_token(Password, Client#mqtt_client.client_id, Client#mqtt_client.username, State).
%% co the can check them co phai la superuser kho: TODO
%% ....

check_token(Token, ClientId, Username, #key{rsakey = RsaPublicKey, algorithm = Algorithm, issuser = Iss}) ->
%%  io:fwrite("TruongLX:check-token: ~p~n", [RsaPublicKey]),
  try
    case jose_jwt:verify_strict(RsaPublicKey, [Algorithm], Token) of
      {true, {_, Payload}, _} ->
%%        io:fwrite("TruongLX:check-token: ~p~n, Alg: ~p~n", [Payload, Algorithm]),
        verify_token:validate(Payload, Iss, Username, ClientId);
      {false, {_, Payload}, _} ->
%%        io:fwrite("TruongLX:check-token-false: ~p~n, Alg: ~p~n", [Payload, Algorithm]),
        {error, token_verify_error}
    end
  catch
    %%Throw o dau thi vao nhanh nay
    MyError -> {error, MyError};
    %%Nhanh nay cho he thong
    _:_ -> {error, valid_}
  end.

description() -> "Authentication with JWT".

