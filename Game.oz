functor
import
   Gui
   Utils
export
   Game
define

   fun {Game InitMap InitPlayers}
	
      fun {Inbox State Msg}
         case State of state(Map Players Playing) then
            case Msg of start then
		{Utils.printf "start"}
            [] stop then
               state(stopped)
	    [] move(Id Position Direction) then
	       local Obj in
               Obj = {Gui.getAt Map Position.x Position.y}
		  if {Label Players.Id} == dead then
		     {Send Players.Id.port invalid(dead Players.Id.pos)}
		     State
		  end
	       end
            [] dead(Id) then
                  {Utils.printf "You have been killed"}
               end
         [] state(stopped) then
            state(stopped)
         end
      end
   in
      {Utils.newPortObject state(InitMap InitPlayers 0) Inbox}
   end
end
