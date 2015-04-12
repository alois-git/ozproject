functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   OS
   Utils
export
   Gui
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

%%%%%%%%%% GUI Utils see below for Gui Port Object %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {GetAt Map X Y}
      if X > 0 andthen X =< WidthInCell andthen Y > 0 andthen Y =< HeightInCell then
         {Utils.printf Map.Y.X}
	 Map.Y.X
      else
	{Utils.printf "Exception"}
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

   proc {InitLayout Map}
      % draw the map textures
      for I in 1..WidthInCell do
	 for J in 1..HeightInCell do
	    {DrawMap Map p(x:I y:J)}
	 end
      end
   end

   proc {UpdatePlayers Players}
       % draw the players
      for I in 1..{Width Players} do
	 {DrawPlayer Players.I up}
      end
   end


   
   proc {LoadTextures}
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

 

   proc {ShowWindow}
      {Window show}
   end
   
   proc {CloseWindow}
      {Send Trainer close()}
      {Window close}
   end
      
   proc {LoadMapWindow Map}
      Desc
   in
      % Loading textures from files
      {LoadTextures}
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
	 
      {InitLayout Map}
      {Window bind(event:"<Up>" action:proc{$} {Send Trainer.port move(up)} end)}
      {Window bind(event:"<Left>" action:proc{$} {Send Trainer.port move(left)} end)}
      {Window bind(event:"<Down>" action:proc{$} {Send Trainer.port move(down)}  end)}
      {Window bind(event:"<Right>" action:proc{$} {Send Trainer.port move(right)} end)}
      {Window bind(event:"<Escape>" action:proc{$} {CloseWindow} end)}
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Gui Trainer InitialMap}
      
      fun{Inbox State Msg}
	 case State of state(starting) then
	    case Msg of start then
	       {Utils.printf "build gui map"}
	       {LoadMapWindow InitialMap}
	       {Utils.printf "showing windows"}
	       {ShowWindow}
	       state(listening)
	    end
	
	 [] state(listening) then
	    case Msg of mapchanged(Map Players) then
	       {UpdatePlayers Players}
	       {Utils.printf "updating map"}
	       State
	    [] lost then
	       {Utils.printf "lost"}
	       State
	    [] win then
	       {Utils.printf "won"}
	       State
	    else
	       State
	    end
	 end
      end
   in
      {Utils.newPortObject state(starting) Inbox}
   end
   
end
