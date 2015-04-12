functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   System
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
	PlayerIcon = Trainer
      {Grid create(image WidthCell*Player.pos.x-(WidthCell div 2) HeightCell*Player.pos.y-(HeightCell div 2) image:PlayerIcon)}
   end

   proc {UpdateMap Map}
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

 
   fun {AskChoiceWild}
    local Y 
       Desc=lr(button(text:"Yes" 
                      return:Y
                      action:toplevel#close)
               button(text:"No" 
                      action:toplevel#close))
    in 
       {{QTk.build Desc} show}
       if Y then true else false end 
    end
  
   end

   proc {ShowWindow}
      {Window show}
   end
   
   proc {CloseWindow}
      {Send Trainer close()}
      {Window close}
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Gui Trainer InitialMap}

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
	 
      {UpdateMap Map}
      {Window bind(event:"<Up>" action:proc{$} {Send Trainer move(up)} end)}
      {Window bind(event:"<Left>" action:proc{$} {Send Trainer move(left)} end)}
      {Window bind(event:"<Down>" action:proc{$} {Send Trainer move(down)}  end)}
      {Window bind(event:"<Right>" action:proc{$} {Send Trainer move(right)} end)}
      {Window bind(event:"<Escape>" action:proc{$} {CloseWindow} end)}
   end
      
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
               {UpdateMap Map}
	       {UpdatePlayers Players}
	       State
            [] choicewild(OtherPokemoz) then
	       {Send Trainer guiwildchoice({AskChoiceWild} OtherPokemoz)}
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