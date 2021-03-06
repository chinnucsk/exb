%% Copyright Dmitrii Dimandt 2009. All Rights Reserved.
%%
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.

%% @author Dmitrii Dimandt <dmitrii@dmitriid.com>

-module(exb_utils).

%%
%% Exported Functions
%%
-export([
		 lib_dir/0,
		 lib_dir/1,
		 plugin_dir/1,
		 read_settings/1,
		 plugin_atom/1
]).

%%
%% API Functions
%%

%% @doc Return path to the application root.
%% Adapted from Zotonic CMS

-spec(lib_dir/0 :: () -> string()).
-spec(lib_dir/1 :: (string()) -> string()).

lib_dir() ->
	{ok, Path} = exb_app:get_path(),
	Path.

%% @doc Return an abspath to a directory relative to the application root.

lib_dir(Dir) ->
	{ok, Path} = exb_app:get_path(),
	filename:join([Path, Dir]).

%% @doc Return an abspath to a directory containing the plugin.
%
% <strong>Usage:</strong>
% <pre><code lang="erlang">
% > exb_utils:plugin_dir(echo).
% > exb_utils:plugin_dir(exb_plugin_echo).
% </code></pre>
%

-spec(plugin_dir/1 :: (atom() | string()) -> string()).

plugin_dir(Plugin) when is_atom(Plugin) ->
	plugin_dir(atom_to_list(Plugin));
plugin_dir(Plugin) ->
	P = case list_to_binary(Plugin) of
		<<"exb_plugin_", ShortName/binary>> -> binary_to_list(ShortName);
		_ -> Plugin
	end,
	exb_utils:lib_dir("priv/plugins/" ++ P).

%% @doc Read and parse a config file. The file must be in a valid Erlang syntax
%
-spec(read_settings/1 :: (string()) -> list()).

read_settings(FileName) ->
	case file:read_file(FileName) of
		{ok, Binary} ->
		    Config = binary_to_list(Binary),
			{ok,Tokens,_} = erl_scan:string(Config),
			{ok,Term} = erl_parse:parse_term(Tokens),
			Term;
		_ ->
			[]
	end.

-spec(plugin_atom/1 :: (atom() | list()) -> atom()).

% @doc Convert short plugin name (such as "echo") to a fully qualified name
%      (such as exb_plugin_echo)
%
plugin_atom(Plugin) when is_atom(Plugin) ->
	plugin_atom(atom_to_list(Plugin));
plugin_atom(Plugin) ->
	list_to_atom("exb_plugin_" ++ Plugin).
