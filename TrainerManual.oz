functor
import
   Utils
   OS
   GameServer
   Map
   Trainer
   Pokemoz

export
   NewTrainerManual

define

   fun {NewTrainerManual Pokemoz Position Direction } % could add an icon ?
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

      Super = {Trainer.newTrainer Pokemoz Position Direction}
      InitTrainerManual = npc(super:Super)

      fun {FunTrainerManual S Msg}
         R NewPos
      in
         case Msg
         of move then
            S % the move will be reflected in super, so the npc state hasns't changed
         [] guimove(NewDirection) then
            if NewDirection == Direction then
               {Send S.super move}
            else
               {Send S.super turn(NewDirection)}
            end
            S
         else
            {Send S.super Msg}
            S
         end
      end

   in
      {Utils.newPortObject InitTrainerManual FunTrainerManual}
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
