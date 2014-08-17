%%%----------------------------------------------------------------
%%% @author Genesislive <genesislive@126.com>
%%%     [https://]
%%% @copyright 2013 
%%% @doc Erlang Sodoku Solver
%%% @end
%%%----------------------------------------------------------------
-module(sudoku_solver).

%% API
-export([solve/1]).

%%%================================================================
%%% API
%%%================================================================

%%-----------------------------------------------------------------
%% @doc 
%% @spec solve(Puzzle) -> ok.
%% where
%%  Puzzle = list(integer())
%% @example
%%  sudoku_solver:solve([0,1,0,0,4,0,5,6,0,2,3,0,6,1,5,0,8,0,0,0,0,8,0,0,1,0,0,0,5,0,0,2,0,0,0,8,6,0,0,7,8,1,0,0,5,9,0,0,0,6,0,0,2,0,0,0,6,0,0,8,0,0,0,0,8,0,4,7,3,0,5,6,0,4,5,0,9,0,0,1,0]).
%% @end
%%-----------------------------------------------------------------
solve(Puzzle) when is_list(Puzzle) ->
    dfs(list_to_dict(Puzzle)).

%%%================================================================
%%% Internal functions
%%%================================================================

%%-----------------------------------------------------------------
%% @doc convert list to dict
%% @spec list_to_dict(Puzzle::dict) -> dict().
%% @end
%%-----------------------------------------------------------------
list_to_dict(Puzzle) ->
    % element
    element(2, lists:foldl(fun(Elm, {Num, Dict}) ->
        {Num + 1, dict:store({Num div 9, Num rem 9}, Elm, Dict)} % dict:store创建一个新dict
    end, {0, dict:new()}, Puzzle)).

%%-----------------------------------------------------------------
%% @doc check if Val is valid for the Nth element of Puzzle
%% @spec check(Puzzle::) -> ok.
%% where
%%  Puzzle is dict of {X, Y}:Value.
%% @end
%%-----------------------------------------------------------------
print(Puzzle) ->
    % io:format("~p~n", [dict:to_list(Puzzle)]),
    lists:foreach(fun(X) ->
        lists:foreach(fun(Y) ->
            io:format("~p ", [dict:fetch({X, Y}, Puzzle)])
        end, lists:seq(0, 8)),
        io:format("~n", [])
    end, lists:seq(0, 8)).

%%-----------------------------------------------------------------
%% @doc check if Val is valid for the Nth element of Puzzle
%% @spec check(N::integer(), Val::integer(), Puzzle::dict()) -> true | false
%% @end
%%-----------------------------------------------------------------
check(N, Val, Puzzle) ->
    case lists:all(fun(Row) ->          % 检查N所在行是否合法
        dict:fetch({Row, N rem 9}, Puzzle) /= Val
    end, lists:seq(0, 8)) of
        false -> false;
        true ->
            case lists:all(fun(Col) ->          % 检查N所在列是否合法
                dict:fetch({N div 9, Col}, Puzzle) /= Val
            end, lists:seq(0, 8)) of
                false -> false;
                true ->
                    Row = N div 9 div 3 * 3,
                    Col = N rem 9 div 3 * 3,
                    case lists:all(fun(X) ->        % 检查格子N所在小九宫是否合法
                        lists:all(fun(Y) ->
                            dict:fetch({X, Y}, Puzzle) /= Val
                        end, lists:seq(Col, Col + 2))
                    end, lists:seq(Row, Row + 2)) of
                        true -> true;
                        false -> false
                    end
            end
    end.

%%-----------------------------------------------------------------
%% @doc solve sudoku using Depth-First-Search
%% @spec dfs(Puzzle:dict()) -> ok
%% @end
%%-----------------------------------------------------------------
dfs(Puzzle) ->
    dfs(0, Puzzle).

dfs(N, Puzzle) when N > 80 ->
    io:format("Solution found.~n"),
    print(Puzzle),
    io:format("~n");
dfs(N, Puzzle) ->
    Val = dict:fetch({N div 9, N rem 9}, Puzzle),
    if
        Val /= 0 -> % 当前位不为空时跳过
            dfs(N + 1, Puzzle);
        Val == 0 -> % enum all possible value
            lists:foreach(fun(Num) ->
                case check(N, Num, Puzzle) of
                    true ->
                        dfs(N + 1, dict:store({N div 9, N rem 9}, Num, Puzzle));
                    false -> failed
                end
            end, lists:seq(1, 9))
    end.
