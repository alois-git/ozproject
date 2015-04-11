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
define

   Printf = System.showInfo

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
	 p(x:P.x+1 y:P.y)
      [] down then
	 p(x:P.x-1 y:P.y)
      [] left then
	 p(x:P.x y:P.y-1)
      [] right then
	 p(x:P.x+1 y:P.y+1)
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
