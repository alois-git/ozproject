functor
import
   Utils
export
   GameServer
define

   fun {GameServer Map Players}

      fun {GetAt Map X Y}
	 local WidthInCell HeightInCell in
	    WidthInCell = {Record.width Map.1}
	    HeightInCell = {Record.width Map}
	    if X > 0 andthen X =< WidthInCell andthen Y > 0 andthen Y =< HeightInCell then
	       Map.Y.X
	    else
	       ~1
	    end
	 end
      end

      fun {Inbox State Msg}
	 case State of state(starting Map Players) then
	    case Msg of start then
	       {Utils.printf "start"}
               for I in 1..{Width Players} do
	          {Send Players.I.port pickpokemoz}
               end
	       state(listening Map Players)
	    else
	       {Utils.printf "server not started please start the server"}
	    end
	 [] state(listening Map Players) then
	    case Msg of stop then
               state(stopped)
	    [] move(Id Position Direction) then
	       local Obj in
               Obj = {GetAt Map Position.x Position.y}
		  if {Label Players.Id} == dead then
		     {Send Players.Id.port invalid(dead Players.Id.pos)}
		     State
		  end
	       end
	    [] runway(Id WildPokemon) then
	       {Utils.printf "Run away from"#WildPokemon}
	    [] fight(Id WildPokemon) then
	       {Utils.printf "fighting"#WildPokemon}
            [] quit() then
	       {Utils.printf "Disconnecting from game"}
	    end
	 [] state(stopped) then
	    state(stopped)
	 end
      end
   in
      {Utils.newPortObject state(starting Map Players) Inbox}
   end
end
