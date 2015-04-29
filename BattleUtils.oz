functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   GameServer
   Pokemoz
   OS

export
   BattleTrainer
   WalkInGrass
   SetupBattle
   DrawBattleUI

define
   Probability
   Type
   Screen

   proc {SetupBattle P}
      F G W CD in
      CD = {OS.getCWD}
      Probability = P
      F = {QTk.newImage photo(file:CD#'/images/type_grass.gif')}
      G = {QTk.newImage photo(file:CD#'/images/type_fire.gif')}
      W = {QTk.newImage photo(file:CD#'/images/type_water.gif')}
      Type = type(fire:F grass:G water:W)
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


   proc {DrawBattleUI Pkmz1 Pkmz2}
      H1 H2 L1 L2 T1 T2 in
      {{QTk.build lr(
                  canvas(  width:900
                           height:900
                           handle:Screen)
                  )}
            show}
      {Send Pkmz1 get(hp ret(H1))}
      {Send Pkmz2 get(hp ret(H2))}
      {Send Pkmz1 get(lx ret(L1))}
      {Send Pkmz2 get(lx ret(L2))}
      {Send Pkmz1 get(type ret(T1))}
      {Send Pkmz2 get(type ret(T2))}
      {Screen create(text 0 0 anchor:nw text:H1)}
      {Screen create(text 0 200 anchor:nw text:L1)}
    
      {Screen create(image 150 0 anchor:nw image:Type.T1)}
      {Screen create(image 450 0 anchor:nw image:Type.T2)}
      
      {Screen create(text 750 0 anchor:nw text:H2)}
      {Screen create(text 750 200 anchor:nw text:L2)}

   end

end
