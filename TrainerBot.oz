functor
import
   Utils
   OS
export
   TrainerBot
define

fun {TrainerBot Trainer InitialMap}

 fun{Inbox State Msg}
	 case State of state(starting) then
	    case Msg of start then
               {Send Trainer pokemonchoosen(grass)}
	       {Utils.printf "Bot choosing pokemoz"}
               state(playing)
            else
               State
	    end
	
	 [] state(playing) then
	    case Msg of mapchanged(_ _) then
	       State
            [] play(_) then
     	       local R in 
                  R = {Abs {OS.rand}} mod 100 + 1
                  if R < 4 then
        	     {Send Trainer move(Utils.moveType.R)}
                  end
                  State
               end
            [] choicewild(OtherPokemoz) then
	       {Utils.printf "Bot calculate if should fight"}
               {Send Trainer guiwildchoice(true OtherPokemoz)}
	       State
	    [] pokemozchanged(_) then
	       State
	    [] lost then
               {Utils.printf "bot lost"}
	       {Send Trainer quit}
	       State
	    [] win then
	       {Utils.printf "won"}
	       State
	    else
	       State
	    end
	 end
      end
   in
      {Utils.newPortObject state(starting) Inbox}
   end
   
end
