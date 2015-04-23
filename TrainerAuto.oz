functor
import
   Utils
   OS
export
   TrainerAuto
define

fun {TrainerAuto Trainer InitialMap}

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
     	       local R in 
                  R = {Abs {OS.rand}} mod 100 + 1
                  if R < 4 then
        	     {Send Trainer move(Utils.moveType.R)}
                  end
                  State
               end
            [] choicewild(OtherPokemoz) then
	       % player should choose to fight or not depending on which wild pokemon
               {Send Trainer guiwildchoice(true OtherPokemoz)}
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