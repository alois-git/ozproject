functor
import
   Utils
   Map
export
   TrainerAuto
define
   
   fun {TrainerAuto Trainer InitialMap}

     
      % get the best move to minimize the manathan distance between the player and the goal + the number of trainer around
      % + the type of terrain of the new position after this new move
      fun {GetNextMove Position JayPosition TrainersNPC}
         % recursive method to get the best move, keeping the current minimum manathan distance and the best move found
	 fun {GetNextMoveRec Position JayPosition TrainersNPC Weight MoveIndex SelectedMove}
	    local NewPosition NewManathanDistance NumberOfTrainerAround TerrainType NewWeight in
	       NewPosition = {Utils.calculateNewPos Position Utils.moveType.MoveIndex}
	       NewManathanDistance = {Abs (JayPosition.x - NewPosition.x)} + {Abs (JayPosition.y - NewPosition.y)}
	       NumberOfTrainerAround = {GetNumberTrainerNPCAround Map.getPositionsAround(NewPosition) TrainersNPC}
               TerrainType = Map.getTerrain(NewPosition)
               NewWeight = NewManathanDistance + NumberOfTrainerAround + TerrainType
               % if we tried all the move return the best found
	       if MoveIndex > 4 then
		  SelectedMove
               % if the new weigth is smaller than the current weight pick this move
	       elseif NewWeight < Weight then
		  {GetNextMoveRec Position JayPosition TrainersNPC NewWeight MoveIndex+1 Utils.moveType.MoveIndex}
               % else just try a new move
	       else
		  {GetNextMoveRec Position JayPosition TrainersNPC Weight MoveIndex+1 SelectedMove}
	       end
	    end
	 end
      in
	 {GetNextMoveRec Position JayPosition TrainersNPC 0 1 none}
      end

      % maybe move that to trainer class and get it with a port message
      fun {IsPosFree Pos Trainers}
         case Trainers
         of H|T then
            local R in
            {Send H get(position ret(R))}
            if R == Pos then
               false
            else
               {IsPosFree Pos T}
            end end
         [] nil then
            true
         end
      end

      % maybe move that to trainer class and get it with a port message
      fun {GetNumberTrainerNPCAround Positions TrainersNPC}
         fun {GetNumberTrainerNPCAroundRec Position TrainersNPC A}
            case Positions of H|T then
                 if {IsPosFree H TrainersNPC} == false then
                    {GetNumberTrainerNPCAroundRec T TrainersNPC A+1}
                 else
                    {GetNumberTrainerNPCAroundRec T TrainersNPC A}
                 end
            [] nil then
               A
            end
         end
         in
          {GetNumberTrainerNPCAroundRec Positions TrainersNPC 0}
      end

      fun{Inbox State Msg}
	 case State of state(starting) then
	    case Msg of start then
	       % player should automaticly choose a pokemon (random)
	       {Send Trainer pokemonchoosen(grass)}
	       state(playing none)
	    else
	       State
	    end
	 [] state(playing Trainers) then
	    case Msg of mapchanged(Trainers) then
	       state(playing Trainers)
	    [] play(_) then
	       % player should analyse the map to know what to play
	       local Position JayPosition in
		  JayPosition = {Map.getJayPosition}
		  {Send Trainer getposition(Position)} 
		  {Send Trainer move({GetNextMove Position JayPosition Trainers})}
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
