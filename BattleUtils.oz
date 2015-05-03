functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   GameServer
   Pokemoz
   OS
   Utils
   Map
export
   BattleTrainer
   WalkInGrass
   SetupBattle
   DrawBattleUI

define
   Probability
   Type

   proc {SetupBattle P}
      F G W CD in
      CD = {OS.getCWD}
      Probability = P
      G = {QTk.newImage photo(file:CD#'/images/type_grass.gif')}
      F = {QTk.newImage photo(file:CD#'/images/type_fire.gif')}
      W = {QTk.newImage photo(file:CD#'/images/type_water.gif')}
      Type = type(fire:F grass:G water:W)
   end

   proc {BattleTrainer NPC Player}
      Enemy Ally in
      {Send NPC get(pkmz ret(Enemy))}
      {Send Player get(pkmz ret(Ally))}
      {Wait Enemy}
      {Wait Ally}
      {Battle Enemy Ally}
   end


   proc {BattleWild Wild Player}
      Pkmz in
      {Send Player get(pkmz ret(Pkmz))}
      {Battle Wild Pkmz}
   end

   proc {Battle Enemy Ally}

      proc {BattleEnemyTurn Enemy Ally Display}
         V in
         {Send Enemy attackedby(Ally)}
         % TODO Display.h1.update ( Enemy.getHealth )
         {Map.updatePlayerPokemozInfo Enemy}
         {Send Enemy isko(ret(V))}
         if V then
            Exp in
            {Send Enemy get(lx ret(Exp))}
            {Send Ally addxp(Exp)}
            {Send GameServer.gameState run}
         else
            {BattleAllyTurn Enemy Ally Display}
         end
      end

      proc {BattleAllyTurn Enemy Ally Display}
         V in
         {Send Ally attackedby(Enemy)}
         % TODO Display.h2.update ( Ally.getHealth )
         {Map.updatePlayerPokemozInfo Ally}
         {Send Ally isko(ret(V))}
         if V then
            {GameServer.stopGameServer defeat}
         else
            {BattleEnemyTurn Enemy Ally Display}
         end
      end
      Ack
      Display
   in
      {Send GameServer.gameState wait(Ack)}
      {Wait Ack}
      Display = {DrawBattleUI Enemy Ally}
      {BattleAllyTurn Enemy Ally Display}
   end

   proc {WalkInGrass Player}
      R in
      R = {Abs {OS.rand}} mod 100
      if R < Probability then
         {BattleWild {Pokemoz.newRandomPokemoz} Player}
      end
   end

   fun {DrawBattleUI Pkmz1 Pkmz2}
      H1 H2 L1 L2 T1 T2 Display Screen in
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

      {Utils.printf T1}

      {Screen create(text 0 0 anchor:nw text:H1)}
      {Screen create(text 0 200 anchor:nw text:L1)}

      {Screen create(image 150 0 anchor:nw image:Type.T1)}
      {Screen create(image 450 0 anchor:nw image:Type.T2)}

      {Screen create(text 750 0 anchor:nw text:H2)}
      {Screen create(text 750 200 anchor:nw text:L2)}

      Display = text(h1:H1 h2:H2)

   end

end
