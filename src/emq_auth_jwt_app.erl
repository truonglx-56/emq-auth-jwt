%%%-------------------------------------------------------------------
%%% @author truonglx
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Apr 2017 13:19
%%%-------------------------------------------------------------------
-module(emq_auth_jwt_app).
-author("truonglx").

-behaviour(application).

-include("emq_auth_jwt.hrl").

-import(emq_auth_jwt_cli, [parse_query/1]).

%% Application callbacks
-export([start/2, prep_stop/1, stop/1]).


%%--------------------------------------------------------------------
%% Application Callbacks
%%--------------------------------------------------------------------

start(_StartType, _StartArgs) ->
  {ok, Sup} = emq_auth_jwt_sup:start_link(),

  if_enabled_rsa(auth_privkey, fun reg_authmod/1),
  if_enabled(acl_query, fun reg_aclmod/1),
  emq_plugin_chat:load(application:get_all_env()),
  {ok, Sup}.

prep_stop(State) ->
  emqttd_access_control:unregister_mod(auth, emq_auth_jwt),
  emqttd_access_control:unregister_mod(acl, emq_acl_jwt),
  State.

stop(_State) ->
  ok.

reg_authmod(RSAPublicJWK) ->
%%  SuperQuery = parse_query(application:get_env(?APP, super_query, undefined)),
  {ok, AlgorithmRaw} = application:get_env(?APP, auth_algorithm),

  Algorithm = list_to_binary(AlgorithmRaw),
  {ok, Iss} = application:get_env(?APP, auth_iss),
  AuthEnv = {RSAPublicJWK, Algorithm, Iss},
%%  io:fwrite("TruongLX:auth_jwt: ~p~n", [AuthEnv]),
  emqttd_access_control:register_mod(auth, emq_auth_jwt, AuthEnv).

reg_aclmod(AclQuery) ->
  {ok, Env} = application:get_env(?APP, mnesia),

  io:fwrite("TruongLX:mnesia: ~p~n", [Env]),
  {ok, AclNomatch} = application:get_env(?APP, acl_nomatch),
  AclEnv = [{AclQuery, AclNomatch}, Env],
  emqttd_access_control:register_mod(acl, emq_acl_jwt, AclEnv).

%%--------------------------------------------------------------------
%% Internal function
%%--------------------------------------------------------------------

if_enabled(Cfg, Fun) ->
  case application:get_env(?APP, Cfg) of
    {ok, Query} ->
%%      io:fwrite("emq_auth_jwt:read_key: ~p~n", [Query]),
      Fun(parse_query(Query));
    undefined ->
      io:fwrite("emq_auth_jwt: ~n"),
      ok
  end.
if_enabled_rsa(Cfg, Fun) ->

  case application:get_env(?APP, Cfg) of
    {ok, Key} ->
%%      io:fwrite("emq_auth_jwt:read_key: ~p~n", [Key]),
      Fun(read_key(Key));
    undefined ->
%%      io:fwrite("emq_auth_jwt:read_key: undefined ~n"),
      ok
  end.
read_key(RsaKey) ->
% RSA
%%  io:fwrite("TruongLX:Key- ~p~n", [jose_jwk:from_pem_file("/media/truecrypt8/rsa/pub.pem")]),
  case jose_jwk:from_pem_file(RsaKey) of
    {error, _} ->
%%      io:fwrite("emq_auth_jwt:read_key_RsaPrivateKey: ~p~n", [<<"Error">>]),
      undefined;
    RsaPrivateKey -> jose_jwk:to_public(RsaPrivateKey)
%%      io:fwrite("emq_auth_jwt:read_key_RsaPublicKey ~p~n", [RSAPublicJWK]),

  end.



