functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   OS
export
   GetAt
   DeleteAt
   GameFinished
   LoadTextures
   LoadMapWindow
   ShowWindow
   CloseWindow

   DrawMap
   DrawPlayer
   UpdateText
define
   WidthInCell
   HeightInCell
   WidthCell
   HeightCell
   HeightText
   MapWidth
   MapHeight
   TargetObjects
   
   CD
   Grass
   Path 
   PlayerUp
   PlayerDown
   PlayerLeft
   PlayerRight
   PokemozGrass
   PokemozFire
   PokemozWater
   Trainer
   MapTextures

   Window
   Grid
   TextCanvas
   
   fun {GetAt Map X Y}
      if X > 0 andthen X =< WidthInCell andthen Y > 0 andthen Y =< HeightInCell then
         Map.Y.X
      else
         ~1
      end
   end

   fun {DeleteAt Map X Y}
      NewMap
   in
      NewMap = {MakeTuple 'map' HeightInCell}
      for I in 1..HeightInCell do
         NewMap.I = {MakeTuple 'r' WidthInCell}
         for J in 1..WidthInCell do
            if I == Y andthen J == X then
               NewMap.I.J = 0
            else
               NewMap.I.J = Map.I.J
            end
         end
      end
      NewMap
   end
   
   proc {GameFinished Text}
      {TextCanvas create(rect 0 0 MapWidth HeightCell fill:gray outline:black)}
      {DrawText Text p(x:(3*(WidthInCell div 4)) y:1)}
   end
   
   proc {UpdateText Objects}
      {TextCanvas create(rect 0 0 MapWidth HeightCell fill:gray outline:black)}
      {DrawText "Pokemon:\t"#Objects#" / "#TargetObjects p(x:5 y:1)}
      {DrawText "Press escape to exit" p(x:(3*(WidthInCell div 4)) y:3)}
   end
   
   proc {DrawMap Map Position}
      % Path = 0 and Grass = 1 but need to add one because start at 1
      local TextureNumber in
      TextureNumber =  {GetAt Map Position.x Position.y}+1
      {DrawImage MapTextures.TextureNumber Position}
      end
   end
   
   proc {DrawImage Image Position}
      {Grid create(image WidthCell*Position.x-(WidthCell div 2) HeightCell*Position.y-(HeightCell div 2) image:Image)}
   end
   
   proc {DrawText Text Position}
      {TextCanvas create(text WidthCell*Position.x-(WidthCell) HeightText*Position.y text:Text)}
   end
   
   proc {DrawPlayer Player Direction}
      PlayerIcon
   in
      if {Label Player} == trainer then
         PlayerIcon = Trainer
      else
         if Direction == up then PlayerIcon = PlayerUp
         elseif Direction == left then PlayerIcon = PlayerLeft
         elseif Direction == down then PlayerIcon = PlayerDown
         else PlayerIcon = PlayerRight
         end
      end
      {Grid create(image WidthCell*Player.pos.x-(WidthCell div 2) HeightCell*Player.pos.y-(HeightCell div 2) image:PlayerIcon)}
   end

   proc {InitLayout Map Players}

      % draw the map textures
      for I in 1..WidthInCell do
         for J in 1..HeightInCell do
            {DrawMap Map p(x:I y:J)}
         end
      end

      % draw the players
      for I in 1..{Width Players} do
         {DrawPlayer Players.I up}
      end
      
      % Update info text
      %{UpdateText Pokemon 1}
   end

   proc {LoadTextures Map}
      CD = {OS.getCWD}
      
      % textures
      Grass = {QTk.newImage photo(file:CD#'/images/grass.gif')}        
      Path = {QTk.newImage photo(file:CD#'/images/path.gif')}         
      Trainer = {QTk.newImage photo(file:CD#'/images/trainer.gif')}   
      PlayerUp = {QTk.newImage photo(file:CD#'/images/braveup.gif')}
      PlayerDown = {QTk.newImage photo(file:CD#'/images/bravedown.gif')}
      PlayerLeft = {QTk.newImage photo(file:CD#'/images/braveleft.gif')}
      PlayerRight = {QTk.newImage photo(file:CD#'/images/braveright.gif')}
      PokemozGrass = {QTk.newImage photo(file:CD#'/images/pGrass.gif')}
      PokemozFire =  {QTk.newImage photo(file:CD#'/images/pFire.gif')}
      PokemozWater =  {QTk.newImage photo(file:CD#'/images/pWate.gif')}

      % Path = 0 and Grass = 1 but need to add one because start at 1
      MapTextures = images(Path Grass)
   end

   proc {LoadMapWindow Map Players Game Grass Path}
      Desc
   in
      WidthInCell = {Record.width Map.1}
      HeightInCell = {Record.width Map}
      WidthCell = 40
      HeightCell = 40
      HeightText = 10
      MapWidth = WidthCell * WidthInCell
      MapHeight = HeightCell * HeightInCell
      
      Desc=td(
              lr(canvas(bg:gray
                        width:MapWidth
                        height:HeightCell
                        handle:TextCanvas))
              lr(canvas(bg:white
                        width:MapWidth
                        height:MapHeight
                        handle:Grid)))
      Window={QTk.build Desc}

      {InitLayout Map Players}
      {Window bind(event:"<Up>" action:proc{$} {Send Players.1.port move(up)} end)}
      {Window bind(event:"<Left>" action:proc{$} {Send Players.1.port move(left)} end)}
      {Window bind(event:"<Down>" action:proc{$} {Send Players.1.port move(down)}  end)}
      {Window bind(event:"<Right>" action:proc{$} {Send Players.1.port move(right)} end)}
      {Window bind(event:"<space>" action:proc{$} {Send Game finish} end)}
      %{Window bind(event:"<Escape>" action:proc{$} {End.endGame} end)}
   end

   proc {ShowWindow}
      {Window show}
   end

   proc {CloseWindow}
      {Window close}
   end
end
