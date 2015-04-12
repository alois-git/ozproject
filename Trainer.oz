functor
import
   Gui
   Utils
   GameServer
export
   Trainer
define
   fun {Trainer Id GameServer Gui}
      
      fun {FightTrainer PlayerPokemoz OtherPlayerPokemoz}
	 true
      end

      fun {FightPokemoz PlayerPokemoz OtherPokemoz}
	 true
      end

      fun {ShouldFight Poke OtherPoke}
	 true
      end
      
      fun {Inbox State Msg}
	 case State of state(pokemozpick Direction) then
	    case Msg of pickpokemoz then
	    {Utils.printf "picking pokemoz"}
	    {Send Gui start}
	    local Pokemoz in 
	       Pokemoz = pokemoz(type:grass maxhp:20 hp:20 lvl:5)
	       state(waiting Direction Pokemoz)
	    end end
	 [] state(waiting Direction Pokemoz) then
	    case Msg of play(Position) then
	       state(playing Direction Position Pokemoz)
	    [] wildpokemoz(WildPokemoz) then
	       {Utils.printf "there is a wild"}
               {Send Gui choicewild(WildPokemoz)}
	       State
	    [] playerfight(OtherPlayer) then
	       State
	    [] fightresult(Result) then
	       State
	    [] mapchanged(Map Players) then
	       {Send Gui mapchanged(Map Players)}
	       State
	    [] invalidaction(Position Msg) then
	       if Msg == dead then
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
	    [] wildpokemoz(WildPokemoz) then
               {Utils.printf "there is a wild"}
               {Send Gui choicewild(WildPokemoz)}
	       State
            [] guiwildchoice(Choice WildPokemoz) then
               if Choice == true then
                  {Send GameServer fight(Id WildPokemoz)}
               else
                  {Send GameServer runway(Id WildPokemoz)}
               end
               State
	    [] playerfight(OtherPlayer) then
	       State
	    [] fightresult(Result) then
	       State
	    [] mapchanged(Map Players) then
	       {Send Gui mapchanged(Map Players)}
	       State
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
