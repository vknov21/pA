-module(ring).
-compile(export_all).

nod()->
	receive
		{_, acknowledge} -> 
			io:format("Successful acknowledgement received by : ~p~n",[self()]);
		{From, transfer} ->
			io:format("Token has been received by : ~p~n",[self()]),
			From ! {self(), acknowledge}			
	end,
	nod().

ring1(List,Token)->
	{ok,L}=io:read("~nPosition of Process which needs token : "),
	L1=[X||X<-L, X<length(List)],
	T=ringAlgo(List,Token,L1,length(List)),
	ring1(L1,T).

ringAlgo(_,Token,_,0) -> Token;

ringAlgo(List,Token,L,Cnt)->
	io:format("~nToken is with Pid:~p~n",[lists:nth(1,lists:nth(Token,List))]),
	case lists:member(Token,L) of
	true->	
		if (Token+1) rem length(List)=/=0 ->
			lists:nth(1,lists:nth((Token+1) rem length(List),List)) ! {lists:nth(1,lists:nth(Token,List)),transfer},
			timer:sleep(1000);
		true ->
			lists:nth(1,lists:nth(1,List)) ! {lists:nth(1,lists:nth(Token,List)),transfer},
			timer:sleep(1000)
		end;
	false->if (Token+1) rem length(List)=/=0 ->
			lists:nth(1,lists:nth((Token+1) rem length(List),List)) ! {lists:nth(1,lists:nth(Token,List)),transfer};
		true ->
			lists:nth(1,lists:nth(1,List)) ! {lists:nth(1,lists:nth(Token,List)),transfer}
		end
	end,
	if(Token+1) rem length(List)=/=0 ->
		ringAlgo(lists:sort((( (List--[lists:nth(Token,List)]) ++ [[lists:nth(1,lists:nth(Token,List)),0]]) -- [lists:nth((Token+1) rem length(List),List)])++[[lists:nth(1,lists:nth((Token+1) rem length(List),List)),1]]),(Token+1) rem length(List),L,Cnt-1);
	true->
		ringAlgo(lists:sort((( (List--[lists:nth(Token,List)]) ++ [[lists:nth(1,lists:nth(Token,List)),0]]) -- [lists:nth((Token+1) rem length(List)+1,List)])++[[lists:nth(1,lists:nth((Token+1) rem length(List)+1,List)),1]]),(Token+1) rem length(List)+1,L,Cnt-1)
	end.

start()->
	{ok,N}=io:read("Enter no. of Processes : "),
	Pid=spawn(?MODULE,nod,[]),
	io:format("Pid : ~p created~n",[Pid]),
	L=create(N-1,[[Pid,1]]),
	io:format("Processes Pids : ~p~nPid : ~p has token~n",[lists:map(fun([X,_])->X end,L),lists:nth(1,lists:nth(1,L))]),
	ring1(L,1).

create(0,L)->
	L;
create(N,L)->
	Pid=spawn(?MODULE,nod,[]),
	io:format("Pid : ~p created~n",[Pid]),
	create(N-1,L++[[Pid,0]]).
