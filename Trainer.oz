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

      fun {FightResult Pokemoz Result Direction Position}
   	if Result == win then
                  {Send Gui pokemozchanged(Pokemoz)}
                  if Position == none then
                     state(playing Direction Position Pokemoz)
                  else
                     state(playing Direction Position Pokemoz)
                  end
               else
                  {Send Gui pokemozchanged(Pokemoz)}
                  {Send Gui lost}
                  state(lost) 
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
	    {Utils.printf "picking pokemoz"}
	    {Send Gui start}
	    local Pokemoz in 
	       Pokemoz = pokemoz(type:grass maxhp:20 hp:20 lvl:5 name:"mypokemoz" xp:0)
	       state(waiting Direction Pokemoz)
	    end end
         [] state(lost) then
            case Msg of quit then
               {Send GameServer quit}
               State
            else
	       State
            end
	 [] state(waiting Direction Pokemoz) then
	    case Msg of play(Position) then
	       state(playing Direction Position Pokemoz)
	    [] wildpokemoz(WildPokemoz) then
               {Wildpokemoz WildPokemoz Pokemoz State}
	    [] playerfight(OtherPlayer) then
	       State
	    [] fightresult(Pokemoz Result) then
               {FightResult Pokemoz Result Direction none}
	    [] mapchanged(Map Players) then
	       {MapChanged Map Players State}
            [] getpokemoz(P) then
               P = Pokemoz
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
	    [] wildpokemoz(WildPokemoz) then
                {Wildpokemoz WildPokemoz Pokemoz State}
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
               {FightResult Pokemoz Result Direction Position}
 	    [] getpokemoz(P) then
               P = Pokemoz
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
