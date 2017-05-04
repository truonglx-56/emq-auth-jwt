%%%-------------------------------------------------------------------
%%% @author truonglx
%%% @copyright (C) 2017, <BKAV>
%%% @doc
%%%
%%% @end
%%% Created : 18. Apr 2017 13:13
%%%-------------------------------------------------------------------

-module(emq_auth_jwt_sup).
-author("truonglx").

-include("emq_auth_jwt.hrl").

-behaviour(supervisor).

-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%--------------------------------------------------------------------
%% Supervisor callbacks
%%--------------------------------------------------------------------

init([]) ->
  %% MySQL Connection Pool.
  {ok, Server} = application:get_env(?APP, server),
  PoolSpec = ecpool:pool_spec(?APP, ?APP, emq_auth_jwt_cli, Server),
  {ok, {{one_for_one, 10, 100}, [PoolSpec]}}.

