functor
import
   Utils
   OS
   GameServer
   Map
   Trainer
   Pokemoz
export
   NewTrainerAuto
define

   fun {NewTrainerAuto Pokemoz Position Direction }
      %% This object represent a player trainer played by the computer
      %% Available messages :
      %%    move -- always forward
      %%    turn(DIRECTION)
      %%       where DIRECTION is one of the following : up down left right
      %%    fight(POKEMOZ) -- tell this trainer pokemoz to attack the other one
      %%       where POKEMOZ is an instance of the pokemoz object representing the enemy
      %%    haslost(ret(RETURN))
      %%       where RETURN in an unbound variable to be bound to either true or false
      %%    get(ATTRIBUTE ret(RETURN))
      %%       where ATTRIBUTES is one of the following : pkmz, pos, dir
      %%       and RETURN is an unbound variable

      Super = {Trainer.newTrainer Pokemoz Position Direction}
      InitTrainerAuto = pc(super:Super)

      fun {FunTrainerAuto S Msg}
        R NewPos Dir in
         case Msg of move(Time) then
            NewMove Position NewPos GameState in
	          {Send S.super get(pos ret(Position))}
            NewMove = {GetNextMove Position {Map.getJayPosition}}
            {Send S.super get(dir ret(Dir))}
            if NewMove == Dir then
               NewPos = {Map.calculateNewPos Position NewMove}
               {Send GameServer.gameState get(state ret(GameState))}
               if GameState == running andthen {Map.getTerrain NewPos.x NewPos.y} \= none andthen {GameServer.isPosFree NewPos} then
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
               {Send S.super turn(NewMove)}
            end
            S
         else
            {Send S.super Msg}
            S
         end
        end
      in
        {Utils.newPortObject InitTrainerAuto FunTrainerAuto}
      end

      % get the best move to minimize the manathan distance between the player and the goal + the number of trainer around
      % + the type of terrain of the new position after this new move
      fun {GetNextMove Position JayPosition}
         % recursive method to get the best move, keeping the current minimum manathan distance and the best move found
        fun {GetNextMoveRec Position JayPosition Weight MoveIndex SelectedMove}

          local NewPosition NewManathanDistance NumberOfTrainerAround TerrainType NewWeight in

           NewPosition = {Utils.calculateNewPos Position Utils.moveType.MoveIndex}
           NewManathanDistance = {Abs (JayPosition.x - NewPosition.x)} + {Abs (JayPosition.y - NewPosition.y)}
           %NumberOfTrainerAround = {GetNumberTrainerNPCAround {Map.getPositionsAround NewPosition}}
           %TerrainType = {Map.getTerrain NewPosition.x NewPosition.y}
           NewWeight = NewManathanDistance
           if MoveIndex > 4 then
             SelectedMove
           elseif NewWeight < Weight then
             {GetNextMoveRec Position JayPosition NewWeight MoveIndex+1 Utils.moveType.MoveIndex}
           else
             {GetNextMoveRec Position JayPosition Weight MoveIndex+1 SelectedMove}
           end

         end
        end
      in

       {GetNextMoveRec Position JayPosition 0 1 up}
      end


      % maybe move that to trainer class and get it with a port message
      fun {GetNumberTrainerNPCAround Positions}
        fun {GetNumberTrainerNPCAroundRec Positions A}
          case Positions of H|T then
             if {GameServer.isPosFree H} == false then
              {GetNumberTrainerNPCAroundRec T A+1}
             else
              {GetNumberTrainerNPCAroundRec T A}
             end
          [] nil then

             A
          end
        end
      in
        {GetNumberTrainerNPCAroundRec Positions 0}
      end

end
