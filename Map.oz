functor
export
   SetupMap
   Redraw
   GetTerrain
   GetJayPosition
   GetPositionsAround
define
   Layout
   Width
   Height

   proc {SetupMap MapLayout}
      %% Setup the map.
      %% MapLayout must be of layout(map:map(r(...) [r(...)]) width:W height:H)
      %%    or default

      if MapLayout == default then
         Layout = map(
                     r(1 1 1 0 0 0 2)
                     r(1 1 1 0 0 1 1)
                     r(1 1 1 0 0 1 1)
                     r(0 0 0 0 0 1 1)
                     r(0 0 0 1 1 1 1)
                     r(0 0 0 1 1 0 0)
                     r(0 0 0 0 0 0 3)
                  )
         Width = 7
         Height = 7
      else
         Layout = MapLayout.map
         Width = MapLayout.width
         Height = MapLayout.height
      end
   end

   proc {Redraw NPCs PC}
      skip
   end

   fun {GetTerrain Pos}
      case Pos of pos(x:X y:Y) then
         if X < 1 orelse y < 1 orelse X > Width orelse Y > Height then
            none
         else
            case Layout.Y.X
            of 0 then road
            [] 1 then grass
            [] 2 then jay
            [] 3 then center
            end
         end
      end
   end

   fun {GetJayPosition}
      {GetJayPositionRec 0 0}
   end

   fun {GetJayPositionRec X Y}
     if {GetTerrain pos(x:X y:Y)} == 2 then
        pos(x:X y:Y)
     elseif X > Width then
       {GetJayPositionRec 0 Y+1}
     elseif Y > Height then
       {GetJayPositionRec X+1 0}
     else
       none
     end
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

   fun {GetPositionsAround Position}
      local Up Down Right Left in
         Up =  {CalculateNewPos Position up}
         Down = {CalculateNewPos Position down}
         Left = {CalculateNewPos Position left}
         Right  = {CalculateNewPos Position right}
         [Up Down Left Right]
      end
   end

end
