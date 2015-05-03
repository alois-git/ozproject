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
      {Battle Enemy Ally false}
   end


   proc {BattleWild Wild Pkmz}
      {Battle Wild Pkmz true}
   end

   proc {Battle Enemy Ally Wild}

      proc {BattleEnemyTurn Enemy Ally}
         V in
         {Send Enemy attackedby(Ally)}
         % Display.h1.update ( Enemy.getHealth )
         {Send Enemy isko(ret(V))}
         if V then
            Exp in
            {Send Enemy get(lx ret(Exp))}
            {Send Ally addxp(Exp)}
            {Map.addMsgConsole "Your have won the combat !"}
            {Map.addMsgConsole "Your Pokemoz Won "#Exp#"XP !"}
            {Map.updatePlayerPokemozInfo Ally}
            {Send GameServer.gameState run}
         else
            {BattleAllyTurn Enemy Ally}
         end
      end

      proc {BattleAllyTurn Enemy Ally}
         V in
         {Send Ally attackedby(Enemy)}
         % Display.h2.update ( Ally.getHealth )
         {Send Ally isko(ret(V))}
         if V then
            {Map.addMsgConsole "Your have lost the combat !"}
            {Map.updatePlayerPokemozInfo Ally}
            {GameServer.stopGameServer defeat}
         else
            {BattleEnemyTurn Enemy Ally}
         end
      end
      Ack
      Fight
   in
      {Send GameServer.gameState wait(Ack)}
      {Wait Ack}
      Fight = {DrawBattleUI Enemy Ally Wild}
      if Fight == true then
        {BattleAllyTurn Enemy Ally}
      else
        {Send GameServer.gameState run}
      end
   end

   proc {WalkInGrass Player}
      R in
      R = {Abs {OS.rand}} mod 100
      if R < Probability then
         {BattleWild {Pokemoz.newRandomPokemoz} Player}
      end
   end

   fun {DrawBattleUI Pkmz1 Pkmz2 Wild}
      H1 H2 L1 L2 T1 T2 MaxH1 MaxH2 Display Screen TextArea R F C in

      if Wild == true then
      {{QTk.build td(
                  canvas(  width:900
                           height:300
                           handle:Screen)
                  canvas(width:800 height:100 handle:TextArea)
                  button(text:"Run away" return:R action:toplevel#close)
                  button(text:"Fight !" return:F action:toplevel#close)
                  )}
            show}
      else
      {{QTk.build td(
                  canvas(  width:900
                           height:300
                           handle:Screen)
                  canvas(width:800 height:100 handle:TextArea)
                  button(text:"Ok" return:C action:toplevel#close)
                  )}
            show}
      end

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

      {TextArea create(text 0 0 anchor:nw text:"You are being attacked !")}

      Display = text(h1:H1 h2:H2)
      if R then
        R in
        R = {Abs {OS.rand}} mod 100
        {Map.addMsgConsole "Trying to run away."}
        if R < RunAwayProbability then
           {Map.addMsgConsole "You ran away"}
           false
        else
           {Map.addMsgConsole "You failed to run away prepare to fight !"}
           true
        end
      else
        true
      end

   end

end
