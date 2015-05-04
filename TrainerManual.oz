functor
import
   Utils
   Trainer
   GameServer
   Map
   BattleUtils
export
   NewTrainerManual

define

   fun {NewTrainerManual Pokemoz Position Direction} % could add an icon ?
      %% This object represent an player trainer
      %% The position and Direction arguments are initial
      %%    Position = pos(x:X y:Y)
      %%    Direction = up, down, left, right
      %% Available messages :
      %%    guimove(NewDirection) -- trigger a movement form the gui (move forward or turn)
      %%    fight(POKEMOZ) -- see Trainer
      %%    haslost(ret(R)) -- see Trainer
      %%    wanttofight(POKEMOZ ret(RETURN))
      %%
      %% This object can trigger a battle with the NPC without it's consent (via BattleUtils)

      Super = {Trainer.newTrainer Pokemoz Position Direction}
      InitTrainerManual = pc(state:waiting super:Super)

      fun {FunTrainerManual S Msg}
         case S of pc(state:waiting super:_) then
            case Msg of move(_) then
              pc(state:playing super:S.super)
            else
              {Send S.super Msg}
              pc(state:waiting super:S.super)
            end
         [] pc(state:playing super:_) then
            case Msg
            of guimove(NewDirection) then
              local P D NewPos Terrain in
              {Send S.super get(pos ret(P))}
              {Send S.super get(dir ret(D))}
              if NewDirection == D then
                  {Send S.super move}
                  NewPos = {Map.calculateNewPos P D}
                  Terrain = {Map.getTerrain NewPos.x NewPos.y}
                  if Terrain == jay then
                     {GameServer.stopGameServer victory}
                  elseif terrain == center then
                     P in
                     {Send S.super get(pkmz ret(P))}
                     {Send P heal}
                  elseif Terrain == grass then
                     thread {BattleUtils.walkInGrass GameServer.pC} end
                  end
              else
                {Send S.super turn(NewDirection)}
              end
              pc(state:waiting super:S.super)
              end
          [] move(_) then
             S
          else
              {Send S.super Msg}
              S
          end
        end
      end

   in
      {Utils.newPortObject InitTrainerManual FunTrainerManual}
   end


end
