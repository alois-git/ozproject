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
   RunAwayProbability
   Type

   proc {SetupBattle P RunAwayP}
      F G W CD in
      CD = {OS.getCWD}
      Probability = P
      RunAwayProbability = RunAwayP
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
      Pkmz
   in
      {Send Player get(pkmz ret(Pkmz))}
      {Battle Wild Pkmz}
   end

   proc {Battle Enemy Ally}

      proc {BattleAllyTurn Enemy Ally}
         V in
         {Send Enemy attackedby(Ally)}
         {Send Enemy isko(ret(V))}
         if V then
            Exp in
            {Send Enemy get(lx ret(Exp))}
            {Send Ally addxp(Exp)}
            {Map.addMsgConsole "Your have won the combat !"}
            {Map.addMsgConsole "Your Pokemoz won "#Exp#"XP !"}
            {Map.updatePlayerPokemozInfo Ally}
            {Send GameServer.gameState run}
         else
            {BattleEnemyTurn Enemy Ally}
         end
      end

      proc {BattleEnemyTurn Enemy Ally}
         V in
         {Send Ally attackedby(Enemy)}
         {Send Ally isko(ret(V))}
         if V then
            {Map.addMsgConsole "Your have lost the combat !"}
            {Map.updatePlayerPokemozInfo Ally}
            {GameServer.stopGameServer defeat}
         else
            {BattleAllyTurn Enemy Ally}
         end
      end
      Ack
      Fight
   in
      {Send GameServer.gameState wait(Ack)}
      {Wait Ack}
      {DrawBattleUI Enemy Ally}
      {BattleAllyTurn Enemy Ally}
   end

   proc {WalkInGrass Player}
      R F Pkmz Ack
   in
      R = {Abs {OS.rand}} mod 100
      if R < Probability then
         {Send GameServer.gameState wait(Ack)}
         {Wait Ack}
         Pkmz = {Pokemoz.newRandomPokemoz}
         if {Utils.wantToFight Pkmz Player} then
            {BattleWild Pkmz Player}
         else
            {Send GameServer.gameState run}
         end
      end
   end

   proc {DrawBattleUI Pkmz1 Pkmz2}
      H1 H2 L1 L2 T1 T2 MaxH1 MaxH2 Display Screen TextArea in

      {{QTk.build td(
                  canvas(  width:900
                           height:300
                           handle:Screen)
                  )}
            show}

      {Send Pkmz1 get(hp ret(H1))}
      {Send Pkmz2 get(hp ret(H2))}

      {Send Pkmz1 get(hpmax ret(MaxH1))}
      {Send Pkmz2 get(hpmax ret(MaxH2))}

      {Send Pkmz1 get(lx ret(L1))}
      {Send Pkmz2 get(lx ret(L2))}

      {Send Pkmz1 get(type ret(T1))}
      {Send Pkmz2 get(type ret(T2))}

      {Screen create(text 0 0 anchor:nw text:"HP: "#H1#"/"#MaxH1)}
      {Screen create(text 0 200 anchor:nw text:"LVL: "#L1)}

      {Screen create(image 150 0 anchor:nw image:Type.T1)}
      {Screen create(image 450 0 anchor:nw image:Type.T2)}

      {Screen create(text 750 0 anchor:nw text:"HP: "#H2#"/"#MaxH2)}
      {Screen create(text 750 200 anchor:nw text:"LVL: "#L2)}

      Display = text(h1:H1 h2:H2)
   end

end
