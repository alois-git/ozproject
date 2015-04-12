functor
import
   Utils
export
   GameServer
define

   fun {GameServer Map Players}

      % function to see if there is a wild pokemoz in the grass
      fun {IsThereWildPokemoz}
	 true
      end

      % Generate a random pokemoz 
      fun {GenerateRandomPokemoz}
	 pokemoz(hp:10 lvl:4)
      end

      % get what type of area is at that position
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
 
      fun {CheckValidPosition Position}
	 local WidthInCell HeightInCell in
	    WidthInCell = {Record.width Map.1}
	    HeightInCell = {Record.width Map}
	    if Position.x > 0 andthen Position.x =< WidthInCell andthen Position.y > 0 andthen  Position.y =< HeightInCell then
	       true
	    else
	       false
	    end
	 end
      end

      % Update a player position in the player list.
      fun {UpdatePlayerPosition Id Player NewPosition}
	 local NewPlayers in
	    NewPlayers = {MakeTuple players {Width Players}}
	    for I in 1..{Width Players} do
     
	       if I == Id then
		  NewPlayers.I = player(port:Player.port pos:NewPosition)   
	       else
		  NewPlayers.I = Players.I
	       end
	    end
	    NewPlayers
	 end
      end

      fun {Inbox State Msg}
	 case State of state(starting Map Players) then
	    case Msg of start then
	       %Start the game tell the player to pick a pokemoz
	       for I in 1..{Width Players} do
		  {Send Players.I.port pickpokemoz}
		  {Send Players.I.port mapchanged(Map Players)}
	       end
	       state(listening Map Players)
	    else
	       {Utils.printf "server not started please start the server"}
	    end
	 [] state(listening Map Players) then
	    case Msg of stop then
	       state(stopped)
	    [] round then
	       for I in 1..{Width Players} do
		  {Send Players.I.port play(Players.I.pos)}
	       end
	       State
	    [] move(Id Position Direction) then
	       local Obj UpdatedPlayers Wild in
		  % Get what type of area it is at that position (grass/road/trainer)
		  Obj = {GetAt Map Position.x Position.y}
		  if {Label Players.Id} == dead then
		     {Send Players.Id.port invalid(dead Players.Id.pos)}
		     State
		  % Check if the position the player want to move to is valid
		  elseif {CheckValidPosition Position} == false then
		     {Send Players.Id.port invalid(wrongmove Players.Id.pos)}
		     State
		  else
		     UpdatedPlayers = {UpdatePlayerPosition Id Players.Id Position}
		     {Send Players.Id.port mapchanged(Map UpdatedPlayers)}
		     % if we are in a grass area check wilpokemoz, danger ! 
		     if Obj == 1 then
			if {IsThereWildPokemoz} == true then
			   {Send Players.Id.port wildpokemoz({GenerateRandomPokemoz})}
			end
		     end
		     state(listening Map UpdatedPlayers)
		  end
	       end
	    [] runway(Id WildPokemoz) then
	       {Utils.printf "Run away from a wild pokemon CHICKEN :D"}
	       State
	    [] fight(Id Pokemoz) then
	       {Utils.printf "fighting a pokemon"}
	       State
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
