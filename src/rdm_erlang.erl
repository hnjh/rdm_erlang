%%%-------------------------------------------------------------------
%%% @author yatung
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. 11月 2019 19:45
%%%-------------------------------------------------------------------
-module(rdm_erlang).
-author("yatung").

-define(VERSION, <<"0.1.0">>).
-define(READONLY, <<"true">>).

%% API exports
-export([main/1]).

%%====================================================================
%% API functions
%%====================================================================

%% escript Entry point
main(Args) ->
    try
        main(Args, []),
	erlang:halt(0)
    catch
        _:_ ->
            Ret = jsx:encode(#{
                <<"error">> => <<"Invalid Erlang Data">>
            }),
            io:fwrite(Ret),
	    erlang:halt(1)
    end.

%%====================================================================
%% Internal functions
%%====================================================================
main(["--version"], _Env) ->
    io:fwrite(?VERSION);
main(["info"], _Env) ->
    Ret = jsx:encode(#{
        <<"version">> => <<"0.1.0">>,
        <<"description">> => <<"Erlang Serialize">>
    }),
    io:fwrite(Ret);
main(["validate"], _Env) ->
    InData = read(),
    Ret = case validate(InData) of
              {ok, _} ->
                  valid_msg();
              error ->
                  invalid_msg()
          end,
    io:fwrite(Ret);
main(["decode"], _Env) ->
    InData = read(),
    OutData = decode(InData),
    Ret = jsx:encode(#{
        <<"output">> => OutData,
        <<"read-only">> => ?READONLY,
        <<"format">> => <<"plain_text">>
    }),
    io:fwrite(Ret);
%% FIXME
main(["encode"], _Env) ->
    InData = read(),
    OutData = encode(?READONLY, InData),
    Ret = jsx:encode(#{
        <<"output">> => OutData
    }),
    io:fwrite(Ret).


validate(Data) ->
    try
        Data = decode(Data),
        {ok, Data}
    catch
        _:_ ->
            error
    end.


decode(Data) ->
    RawData = base64:decode(Data),
    try
        Term = binary_to_term(RawData),
        iolist_to_binary(io_lib:format("~p", [Term]))
    catch
        Class:Reason ->
            error({Class, Reason})
    end.

encode(_ReadOnly= <<"true">>, _) ->
    <<"[WARNNING] Read Only">>;
encode(<<"false">>, Data) ->
    encode(Data).

encode(Data) ->
    RawData = binary_to_list(base64:decode(Data)),
    Term = scan_and_parse(RawData),
    BinData = term_to_binary(Term),
    base64:encode(BinData).


scan_and_parse(RawData) ->
    case erl_scan:string(RawData++".") of
        {ok, Tokens, _Loc} ->
            parse_term(Tokens);
        {error, Error, _Loc} ->
            error(Error)
    end.


parse_term(Tokens) ->
    case erl_parse:parse_term(Tokens) of
        {ok, Term} ->
            Term;
        {error, Error} ->
            error(Error)
    end.


read() ->
    read("").
read(Acc) ->
    case file:read(standard_io, 10) of
        {ok, Data} ->
            read(Acc++Data);
        eof ->
            Acc;
        {error, Error} ->
            error(Error)
    end.


valid_msg() ->
    jsx:encode(#{
        <<"valid">> => <<"true">>,
        <<"error">> => <<>>
    }).


invalid_msg() ->
    jsx:encode(#{
        <<"valid">> => <<"false">>,
        <<"error">> => <<"Input Error">>
    }).

