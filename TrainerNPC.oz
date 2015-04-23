functor
import
   Utils
   OS
export
   TrainerNPC
define

fun {TrainerNPC Trainer InitialMap}

 fun{Inbox State Msg}
	 case State of state(starting Map) then
	    case Msg of start then
               % TrainerNPC could be initialize with a pokemon to choose from
	       % or random (for now)
               local R in
                  R = ({Abs {OS.rand}} mod 2) +1
                  {Send Trainer pokemonchoosen(Utils.pokemozType.R)}
               end
               state(playing Map)
            else
               State
	    end
	
	 [] state(playing Map) then
	    case Msg of mapchanged(Map _) then
	       state(playing Map)
            [] play(_) then
                % should not move or move just a bit 
                % horizontaly or verticaly
                % but should not go into the grass 
            	State
            % should not received this message 
	    [] choicewild(OtherPokemoz) then
               {Send Trainer guiwildchoice(false OtherPokemoz)}
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
