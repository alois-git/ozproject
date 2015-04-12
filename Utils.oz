functor
import
   System
   Open
   Pickle
export
   NewPortObject
   Printf
   CalculateNewPos
   MoveType
   AutoFight
   LoadMapFile
   PokemozType
   PokemozMaxHp
   PokemozXPNeeded
define

   Printf = System.showInfo

   PokemozType = pokemoztype(water grass fire)
  
   PokemozMaxHp = pokemozmaxhp(20 22 24 26 28 30)
   
   PokemozXPNeeded = pokemozxpneeded(0 5 12 20 30 50)

   fun {NewPortObject Init Fun}  
      proc {MsgLoop S1 State}
	 case S1 of Msg|S2 then
	    {MsgLoop S2 {Fun State Msg}}
	 [] nil then skip end
      end
      Sin
   in
      thread {MsgLoop Sin Init} end
      {NewPort Sin}
   end

   fun {CalculateNewPos P MoveType}
      case MoveType of up then
	 p(x:P.x y:P.y-1)
      [] down then
	 p(x:P.x y:P.y+1)
      [] left then
	 p(x:P.x-1 y:P.y)
      [] right then
	 p(x:P.x+1 y:P.y)
      end
   end

   fun {LoadMapFile URL}
      F={New Open.file init(url:URL flags:[read])}
      Map
   in
      try
         VBS
      in
         {F read(size:all list:VBS)}
         % Without adding the intermediary Map, it wouldn't work
         Map = VBS
         Map
      finally
         {F close}
      end
   end

   MoveType = movetype(up down right left)

   AutoFight = 0

end
