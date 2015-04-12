functor
import
   Gui
   Utils
   GameServer
export
   Trainer
define
   fun {Trainer Id GameServer Gui AUTOFIGHT}
      
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
	       Pokemoz = pokemoz(type:grass maxhp:20 hp:20 lvl:5 name:"mypokemoz" xp:0)
	       state(waiting Direction Pokemoz)
	    end end
	 [] state(waiting Direction Pokemoz) then
	    case Msg of play(Position) then
	       state(playing Direction Position Pokemoz)
	    [] wildpokemoz(WildPokemoz) then
               if AUTOFIGHT == 0 then
                {Send GameServer runway(Id WildPokemoz)}
               elseif AUTOFIGHT == 1 then
		{Send GameServer fight(Id Pokemoz WildPokemoz)}
               else
                {Send Gui choicewild(WildPokemoz)}
               end
	       State
	    [] playerfight(OtherPlayer) then
	       State
	    [] fightresult(Pokemoz Result) then
               {Send Gui pokemozchanged(Pokemoz)}
	       state(playing Direction Pokemoz)
	    [] mapchanged(Map Players) then
	       {Send Gui mapchanged(Map Players)}
	       State
            [] getpokemoz(P) then
               P = Pokemoz
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
               if AUTOFIGHT == 0 then
                {Send GameServer runway(Id WildPokemoz)}
               elseif AUTOFIGHT == 1 then
		{Send GameServer fight(Id Pokemoz WildPokemoz)}
               else
                {Send Gui choicewild(WildPokemoz)}
               end
	       State
            [] guiwildchoice(Choice WildPokemoz) then
               if Choice == true then
                  {Send GameServer fight(Id Pokemoz WildPokemoz)}
               else
                  {Send GameServer runway(Id WildPokemoz)}
               end
               State
	    [] playerfight(OtherPlayer) then
	       State
	    [] fightresult(Pokemoz Result) then
               {Send Gui pokemozchanged(Pokemoz)}
	       state(playing Direction Position Pokemoz)
 	    [] getpokemoz(P) then
               P = Pokemoz
	       State
	    [] mapchanged(Map Players) then
	       {Send Gui mapchanged(Map Players)}
	       State
	    [] invalidaction(Position Msg) then
               {Utils.printf "invalid move"}
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
