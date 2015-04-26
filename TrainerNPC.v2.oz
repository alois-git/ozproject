functor
import
   Utils
   OS
   GameServer
   Map
   Trainer
   Pokemoz

export
   NewTrainerNPC

define

   fun {NewTrainerNPC Position Direction Move Range} % could add an icon ?
      %% This object represent an NPC trainer
      %% The position and Direction arguments are initial
      %%    Position = pos(x:X y:Y)
      %%    Direction = up, down, left, right
      %% The move argument indicate wheter the NPC should move when he receive a move message
      %% The range argument indicate how far the npc can see the player
      %% Available messages :
      %%    move -- trigger a movement (move forward or turn)
      %%    look -- make the NPC search the player
      %%    fight(POKEMOZ) -- see Trainer
      %%    haslost(ret(R)) -- see Trainer
      %%
      %% This object can trigger a battle with the NPC without it's consent (via BattleUtils)

      Super = {Trainer.newTrainer {Pokemoz.newRandomPokemoz} Position Direction}
      InitTrainerNPC = npc(super:Super move:Move range:Range)

      fun {FunTrainerNPC S Msg}
         R NewPos
      in
         case Msg
         of move then
            if S.move then % skip this part if the npc is set not to move
               R = {Abs {OS.rand}} mod 100
               if R < 25 then
                  local P D in
                     {Send S.super get(pos ret(P))}
                     {Send S.super get(dir ret(D))}
                     NewPos = {Map.calculateNewPos P D}
                     if {Map.getTerrain NewPos.x NewPos.y} == road andthen {GameServer.isPosFree NewPos} then
                        {Send S.super move}
                     end
                  end
               elseif R < 73 then
                  if     R < 37 then {Send S.super turn(up)}
                  elseif R < 49 then {Send S.super turn(right)}
                  elseif R < 61 then {Send S.super turn(down)}
                  else {Send S.super turn(left)}
                  end
               end
            end
            S % the move will be reflected in super, so the npc state hasns't changed
         [] look then
            P D in
            {Send S.super get(pos ret(P))}
            {Send S.super get(dir ret(D))}
            if {SearchForPlayer P D S.range} then
               {MoveToPlayer P D S.super}
               % {BattleUtils.startTrainerBattle S.super GameServer.pC}
            end
            S
         else
            {Send S.super Msg}
            S
         end
      end

   in
      {Utils.newPortObject InitTrainerNPC FunTrainerNPC}
   end




   fun {SearchForPlayer Pos Dir Range}
      if Range =< 0 then false
      else
         NewPos PCpos in
         NewPos = {Map.calculateNewPos Pos Dir}
         {Send GameServer.pC get(pos ret(PCpos))}
         if NewPos == PCpos then true
         elseif {GameServer.isFree Pos} == false then false
         else {SearchForPlayer NewPos Dir Range-1}
         end
      end
   end

   proc {MoveToPlayer Pos Dir Trainer}
      NewPos
   in
      %% This function assume that the move is possible. Always call SearchForPlayer first.
      NewPos = {Map.calculateNewPos Pos Dir}
      if {GameServer.isFree NewPos} then
         {Send Trainer move}
         {MoveToPlayer NewPos Dir Trainer}
      end
   end
end
