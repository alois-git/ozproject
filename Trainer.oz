functor
import
%   Gui
   Utils
%   GameServer
export
   Trainer
define
   fun {Trainer Id GameServer Gui AUTOFIGHT}
      
%      fun {FightTrainer PlayerPokemoz OtherPlayerPokemoz}
%	 true
%      end
%
%      fun {FightPokemoz PlayerPokemoz OtherPokemoz}
%	 true
%      end
%
%      fun {ShouldFight Poke OtherPoke}
%	 true
%      end

      fun {FightResult Pokemoz Result Direction Position}
   	if Result == win then
                  {Send Gui consolemsg("You have win the fight congratulation !")}
                  {Send Gui pokemozchanged(Pokemoz Result)}
                  if Position == none then
                     state(waiting Direction Pokemoz)
                  else
                     state(playing Direction Position Pokemoz)
                  end
               else
                  {Send Gui consolemsg("You have lost the fight too bad.")}
                  {Send Gui lost(Pokemoz)}               
                  {Send GameServer leave(Id)}
                  state(lost Pokemoz) 
        end
     end


      fun {Wildpokemoz WildPokemoz Pokemoz State}
	     if AUTOFIGHT == 0 then
                {Send GameServer runway(Id WildPokemoz)}
               elseif AUTOFIGHT == 1 then
		{Send GameServer fight(Id Pokemoz WildPokemoz)}
               else
                {Send Gui choicewild(WildPokemoz)}
               end
	       State
      end

      fun {MapChanged Map Players State}
	 {Send Gui mapchanged(Map Players)}
	 State
      end
      
      fun {Inbox State Msg}
	 case State of state(pokemozpick Direction) then
	    case Msg of pickpokemoz then
	      {Send Gui start}
	      state(guistarted Direction)
             end
         [] state(guistarted Direction) then
            case Msg of mapchanged(Map Players) then
	       {MapChanged Map Players State}
	    [] pokemonchoosen(Type) then
   	      local Pokemoz in 
	        Pokemoz = pokemoz(type:Type maxhp:20 hp:20 lvl:5 name:"Player Pokemoz" xp:0)
                {Send Gui consolemsg("You have choose a pokemoz of type"#Pokemoz.type)}
	        state(waiting Direction Pokemoz)
	      end 
            else
              State
            end
         [] state(lost Pokemoz) then
            case Msg of getpokemoz(P) then
               P = Pokemoz
               State
            else
              State
            end
	 [] state(waiting Direction Pokemoz) then
	    case Msg of play(Position) then
               {Send Gui play(Position)}
	       state(playing Direction Position Pokemoz)
	    [] wildpokemoz(WildPokemoz) then
               {Wildpokemoz WildPokemoz Pokemoz State}
	    [] playerfight(_) then
	       State
	    [] fightresult(Pokemoz Result) then
               {FightResult Pokemoz Result Direction none}
	    [] mapchanged(Map Players) then
	       {MapChanged Map Players State}
            [] getpokemoz(P) then
               P = Pokemoz
               State
            [] getdirection(D) then
               D = Direction
               State
            [] guiwildchoice(Choice WildPokemoz) then
               if Choice == true then
                  {Send GameServer fight(Id Pokemoz WildPokemoz)}
               else
                  {Send GameServer runway(Id WildPokemoz)}
               end
               State
	    [] invalidaction(Position Msg) then
	       if Msg == lost then
		  State
	       else
		  state(playing Direction Position Pokemoz)
	       end
	    else
	       State
	    end
	    
	 [] state(playing Direction Position Pokemoz) then
	    case Msg of move(MoveType) then             
	       {Send GameServer move(Id {Utils.calculateNewPos Position MoveType} MoveType)}
	       state(waiting MoveType Pokemoz)
            [] play(Position) then
               {Send Gui play(Position)}
               State
	    [] wildpokemoz(WildPokemoz) then
               {Wildpokemoz WildPokemoz Pokemoz State}
            [] guiwildchoice(Choice WildPokemoz) then
               if Choice == true then
                  {Send GameServer fight(Id Pokemoz WildPokemoz)}
               else
                  {Send Gui consolemsg("You are trying to run away from "#WildPokemoz.name)}
                  {Send GameServer runway(Id WildPokemoz)}
               end
               State
	    [] playerfight(_) then
	       State
	    [] fightresult(Pokemoz Result) then
               {FightResult Pokemoz Result Direction Position}
 	    [] getpokemoz(P) then
               P = Pokemoz
	       State
     	    [] getdirection(D) then
               D = Direction
               State
            [] getposition(P) then
               P = Position
               State
	    [] mapchanged(Map Players) then
	       {MapChanged Map Players State}
	    else
	       State
	    end
	 end
      end
   in
      % creating new player with up direction and state to choose initial pokemoz
	{Utils.newPortObject state(pokemozpick up) Inbox}
   end
end
