functor
import
   Utils
export
   TrainerAuto
define

fun {TrainerAuto Trainer InitialMap}

 % get the best move to minimize the manathan distance between the player and the goal
 fun {GetNextMove Position JayPosition}
    local ManathanD in
       ManathanD = {Abs (JayPosition.x - Position.x)} + {Abs (JayPosition.y - Position.y)}
       {GetNextMoveRec Position JayPosition ManathanD 1 Utils.moveType.1}
    end
 end
 
 % recursive method to get the best move, keeping the current minimum manathan distance and the best move found
 fun {GetNextMoveRec Position JayPosition ManathanDistance MoveIndex SelectedMove}
    local NewPosition NewManathanDistance in
      NewPosition = {Utils.calculateNewPos Position Utils.moveType.MoveIndex}
      NewManathanDistance = {Abs (JayPosition.x - NewPosition.x)} + {Abs (JayPosition.y - NewPosition.y)}
      % if we tried all the move return the best found
      if MoveIndex > 4 then
         SelectedMove
      % if the current manathan distance is smaller take it as the minimum and change the selected move
      elseif NewManathanDistance < ManathanDistance then
        {GetNextMoveRec Position JayPosition NewManathanDistance MoveIndex+1 Utils.moveType.MoveIndex}
      % else just try a new move
      else
        {GetNextMoveRec Position JayPosition ManathanDistance MoveIndex+1 SelectedMove}
      end
    end
 end

 fun{Inbox State Msg}
	 case State of state(starting Map) then
	    case Msg of start then
	       % player should automaticly choose a pokemon (random)
               {Send Trainer pokemonchoosen(grass)}
               state(playing Map)
            else
               State
	    end
	 [] state(playing Map) then
	    case Msg of mapchanged(Map _) then
	       state(playing Map)
            [] play(_) then
	       % player should analyse the map to know what to play
     	       local Position JayPosition in
                  JayPosition = {Map.getJayPosition}
                  {Send Trainer getposition(Position)} 
        	  {Send Trainer move({GetNextMove Position JayPosition})}
                  State
               end
            [] choicewild(OtherPokemoz) then
	       % player should choose to fight or not depending on which wild pokemon
               % depending on type / level / current pokemoz hp
               % evaluation functions is as a weighted sum of various factors
               local R Pokemoz in
                  {Send Trainer getpokemoz(Pokemoz)}
                  R = 1* Pokemoz.lvl - 1* OtherPokemoz.lvl + 2 * Pokemoz.hp
                  if R > 20 then
                    {Send Trainer guiwildchoice(true OtherPokemoz)}
                  else
                    {Send Trainer guiwildchoice(false OtherPokemoz)}
                  end
               end
	       State
	    [] pokemozchanged(_) then
	       State
	    [] lost then
	       {Send Trainer quit}
	       State
	    [] win then
	       State
	    else
	       State
	    end
	 end
      end
   in
      {Utils.newPortObject state(starting InitialMap) Inbox}
   end
   
end
