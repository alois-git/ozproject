functor
import
   Utils
   Trainer

export
   NewTrainerManual

define

   fun {NewTrainerManual Pokemoz Position Direction } % could add an icon ?
      %% This object represent an player trainer
      %% The position and Direction arguments are initial
      %%    Position = pos(x:X y:Y)
      %%    Direction = up, down, left, right
      %% Available messages :
      %%    guimove(NewDirection) -- trigger a movement form the gui (move forward or turn)
      %%    fight(POKEMOZ) -- see Trainer
      %%    haslost(ret(R)) -- see Trainer
      %%
      %% This object can trigger a battle with the NPC without it's consent (via BattleUtils)

      Super = {Trainer.newTrainer Pokemoz Position Direction}
      InitTrainerManual = npc(super:Super)

      fun {FunTrainerManual S Msg}
         case Msg
         of guimove(NewDirection) then
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
end
