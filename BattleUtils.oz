functor
import
   GameServer
   Pokemoz
   OS

export
   BattleTrainer
   WalkInGrass
   SetupBattle

define
   Probability

   proc {SetupBattle P}
      Probability = P
   end

   proc {BattleTrainer NPC Player}

      proc {BattleTrainerPlayerTurn NPC Player}
         %% TODO Gui
         PA PE V in
         {Send Player get(pkmz ret(PA))}
         {Send NPC get(pkmz ret(PE))}
         {Send Player fight(PE)}
         {Send NPC haslost(ret(V))}
         if V then
            Exp in
            {Send PE get(lx ret(Exp))}
            {Send PA addxp(Exp)}
            %% TODO Close Gui ?
            {Send GameServer.gameState run}
         else
            {BattleTrainerNPCTurn NPC Player}
         end
      end

      proc {BattleTrainerNPCTurn NPC Player}
         %% TODO Gui
         PA V in
         {Send Player get(pkmz ret(PA))}
         {Send NPC fight(PA)}
         {Send Player haslost(ret(V))}
         if V then
            {GameServer.stopGameServer defeat}
            %% TODO Close Gui ?
         else
            {BattleTrainerPlayerTurn NPC Player}
         end
      end
      Ack
   in
      {Send GameServer.gameState wait(Ack)}
      {Wait Ack}
      {BattleTrainerPlayerTurn NPC Player}
   end


   proc {BattleWild Pokemoz Player}

      proc {BattleWildPlayerTurn Pokemoz Player}
         %% TODO Gui
         PA V in
         {Send Player get(pkmz ret(PA))}
         {Send Player fight(Pokemoz)}
         {Send Pokemoz isko(ret(V))}
         if V then
            Exp in
            {Send Pokemoz get(lx ret(Exp))}
            {Send PA addxp(Exp)}
            %% TODO Close Gui ?
            {Send GameServer.gameState run}
         else
            {BattleWildPkmzTurn Pokemoz Player}
         end
      end

      proc {BattleWildPkmzTurn Pokemoz Player}
         %% TODO Gui
         PA V in
         {Send Player get(pkmz ret(PA))}
         {Send  Pokemoz attackedby(PA)}
         {Send Player haslost(ret(V))}
         if V then
            {GameServer.stopGameServer defeat}
            %% TODO Close Gui ?
         else
            {BattleWildPlayerTurn Pokemoz Player}
         end
      end
      Ack
   in
      {Send GameServer.gameState wait(Ack)}
      {Wait Ack}
      {BattleWildPlayerTurn Pokemoz Player}
   end
      

   proc {WalkInGrass Player}
      R in
      R = {Abs {OS.rand}} mod 100
      if R < Probability then
         {BattleWild {Pokemoz.newRandomPokemoz} Player}
      end
   end


end
