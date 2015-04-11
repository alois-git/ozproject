functor
import
   Gui
   Utils
export
   Trainer
define
   fun {Trainer Id Game Pokemoz}
      
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
	 case State of state(waiting Direction Pokemoz) then
	    
	    case Msg of play(Position Object) then
	       state(playing Direction Position Pokemoz)
	    [] wildpokemoz(Position OtherPokemoz) then
	       State
	    [] player(Postion OtherPlayer) then
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
	       {Gui.drawPlayer player(port:_ pos:Position) MoveType}
	       {Send Game move(Id {Utils.calculateNewPos Position MoveType} MoveType)}
	       state(waiting MoveType Pokemoz)
	    [] wildpokemoz(OtherPokemoz) then
	       State
	    [] player(OtherPlayer) then
	       State
	    else
	       State
	    end
	 end
      end
   in
      % creating new player with up direction and initial Pokemon
	{Utils.newPortObject state(waiting up Pokemoz) Inbox}
   end
end
