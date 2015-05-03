functor
import
   Utils
   Trainer
   GameServer
   Map
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
      InitTrainerManual = pc(state:waiting super:Super)

      fun {FunTrainerManual S Msg}
         NewPos in
         case S of pc(state:waiting super:_) then
            case Msg of move(Time) then
              {Utils.printf "play"}
              pc(state:playing super:S.super)
            else
              {Send S.super Msg}
              pc(state:waiting super:S.super)
            end
         [] pc(state:playing super:_) then
            case Msg
            of guimove(NewDirection) then
               local P D CurrentGameState Dir in
               {Send S.super get(pos ret(P))}
               {Send S.super get(dir ret(D))}
               if NewDirection == D then
                  {Send GameServer.gameState get(ret(CurrentGameState))}

                  NewPos = {Map.calculateNewPos P D}
                  %%{Utils.printf {GameServer.isPosFree NewPos}}
                  %%andthen {GameServer.isPosFree NewPos}
                  if CurrentGameState == running andthen {Map.getTerrain NewPos.x NewPos.y} \= none  then
                     {Send S.super move}
                  end
                  local Jay Center in
                     Jay = {Map.getJayPosition}
                     Center = {Map.getCenterPosition}
                     if NewPos.x == Jay.x andthen NewPos.y == Jay.y then
                        {GameServer.stopGameServer victory}
                     elseif NewPos.x == Center.x andthen NewPos.y == Center.y then
                        P in
                        {Send S.super get(pkmz ret(P))}
                        {Send P heal}
                     end
                  end
               else
                  {Send S.super turn(NewDirection)}
               end
               pc(state:waiting super:S.super)
            end
          [] move(Time) then
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
