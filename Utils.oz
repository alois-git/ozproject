functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   OS
   System
   Open
   PokemozMain
export
   NewPortObject
   Printf
   CalculateNewPos
   MoveType
   LoadMapFile
   PickMode
   PickPokemoz
   WantToFight
define
   Mode

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
	 p(x:P.x y:P.y-1)
      [] down then
	 p(x:P.x y:P.y+1)
      [] left then
	 p(x:P.x-1 y:P.y)
      [] right then
	 p(x:P.x+1 y:P.y)
      else
      p(x:P.x y:P.y)
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

   fun {PickPokemoz}
     local G W F ImgF ImgG ImgW CD
        CD = {OS.getCWD}
        ImgG = {QTk.newImage photo(file:CD#'/images/type_grass.gif')}
        ImgF = {QTk.newImage photo(file:CD#'/images/type_fire.gif')}
        ImgW = {QTk.newImage photo(file:CD#'/images/type_water.gif')}
        Desc=lr(label(init: "Pick the type of your pokemon")
                button(image:ImgG return:G action:toplevel#close)
                button(image:ImgW return:W action:toplevel#close)
                button(image:ImgF return:F action:toplevel#close))
     in
        {{QTk.build Desc} show}
        if G then grass elseif W then water elseif F then fire end
     end
   end

   fun {PickMode}
     local A M
        Desc=lr(label(init: "Which mode do you want ?")
                button(text:"Auto" return:A action:toplevel#close)
                button(text:"Manual" return:M action:toplevel#close))
     in
        {{QTk.build Desc} show}
        if A then Mode=auto else Mode=manual end
        Mode
     end
   end

   MoveType = movetype(up down right left stay)

   fun {WantToFight Pkmz Player}
      T L Y N 
      Desc = lr(label(init:"You are attacked by a Pokemoz of type "#T#" and level "#L#". Do you want to fight ?")
               button(text:"Yes" return:Y action:toplevel#close)
               button(text:"No" return:N action:toplevel#close))
   in
       {Send Pkmz get(lx ret(L))}
       {Send Pkmz get(type ret(T))}
       if Mode == manual then
          {{QTk.build Desc} show}
          if Y then true else false end
       else
          PokemozMain.args.autofight == 2
      end
   end


end
