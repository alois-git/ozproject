functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
%  System
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
   
   CD
   Grass
   Path 
   PokemozGrass
   PokemozFire
   PokemozWater
   Trainer
   TrainerUp
   TrainerDown
   TrainerLeft
   TrainerRight
   MapTextures
   PokemozTextures

   Window
   Grid
   Console
   TextCanvas

%%%%%%%%%% GUI Utils see below for Gui Port Object %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   proc {UpdatePlayerInfo Player}
      local P in
	 {Send Player.port getpokemoz(P)}
	 {UpdatePlayerPokemozInfo P none}
      end
   end

   proc {UpdatePlayerPokemozInfo P R}
      %if R == win then
         % if lvlup Pokemon gained a boost 346 EXP. Points !
      %end
      {TextCanvas create(rect 0 0 MapWidth HeightCell*2 fill:gray outline:gray)}
      {DrawText "Pokemon:\t"#P.name p(x:4 y:2)}
      {DrawText "HP:\t"#P.hp p(x:4 y:3)}
      {DrawText "XP:\t"#P.xp p(x:4 y:4)}
      {DrawText "Level:\t"#P.lvl p(x:4 y:5)}
      {DrawText "Type:\t"#P.type p(x:4 y:6)}
      %{DrawImageTextCanvas PokemozGrass p(x:1 y:2)}
   end
   
   
   proc {DrawMap Map Position}
      % Path = 0 and Grass = 1 but need to add one because start at 1
      local TextureNumber in
	 TextureNumber =  {Map.getTerrain Position.x Position.y}+1
	 {DrawImage MapTextures.TextureNumber Position}
      end
   end

%   proc {DrawImageTextCanvas Image Position}
%      {TextCanvas create(image WidthCell*Position.x-(WidthCell div 2) HeightCell*Position.y-(HeightCell div 2) image:Image)}
%   end
   
   proc {DrawImage Image Position}
      {Grid create(image WidthCell*Position.x-(WidthCell div 2) HeightCell*Position.y-(HeightCell div 2) image:Image)}
   end
   
   proc {DrawText Text Position}
      {TextCanvas create(text WidthCell*Position.x-(WidthCell) HeightText*Position.y text:Text)}
   end
   
   proc {DrawPlayer Player Direction}
      PlayerIcon
   in
        case Direction of up then
	     PlayerIcon = TrainerUp
        [] down then
             PlayerIcon = TrainerDown
        [] right then
             PlayerIcon = TrainerRight
        else
            PlayerIcon = TrainerLeft
        end
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
	 {DrawPlayer Players.I Players.I.direction}
      end
   end

   proc {AddMsgConsole Msg ConsoleIndex}
      % insert(I LVS): Inserts the list of virtual strings LVS just before the element at position I.
      {Console insert(ConsoleIndex [Msg])}	
   end
   
   proc {LoadTextures}
      CD = {OS.getCWD}
      
      % textures
      Grass = {QTk.newImage photo(file:CD#'/images/grass.gif')}        
      Path = {QTk.newImage photo(file:CD#'/images/path.gif')}         
      Trainer = {QTk.newImage photo(file:CD#'/images/trainer.gif')}   
      PokemozGrass = {QTk.newImage photo(file:CD#'/images/pGrass.gif')}
      PokemozFire =  {QTk.newImage photo(file:CD#'/images/pFire.gif')}
      PokemozWater =  {QTk.newImage photo(file:CD#'/images/pWater.gif')}
      TrainerUp = {QTk.newImage photo(file:CD#'/images/trainerUp.gif')}   
      TrainerDown = {QTk.newImage photo(file:CD#'/images/trainerDown.gif')}   
      TrainerLeft = {QTk.newImage photo(file:CD#'/images/trainerLeft.gif')}   
      TrainerRight = {QTk.newImage photo(file:CD#'/images/trainerRight.gif')}   

      % Path = 0 and Grass = 1 but need to add one because start at 1
      MapTextures = maptextures(Path Grass)
      PokemozTextures = poketextures(PokemozGrass PokemozFire PokemozWater)
   end

 
   fun {AskChoiceWild OtherPokemoz}
    local Y 
       Desc=lr(label(init: OtherPokemoz.name#"is attacking you what do you want to do ? \n Level: "#OtherPokemoz.lvl#" HP : "#OtherPokemoz.hp#" Type : "#OtherPokemoz.type)
		button(text:"Attack" 
                      return:Y
                      action:toplevel#close)
               button(text:"Run away" 
                      action:toplevel#close))
    in 
       {{QTk.build Desc} show}
       if Y then true else false end 
    end  
  end

  fun {Lost}
    local Y 
       Desc=lr(label(init: "Your pokemoz got killed, you have lost ! sad :( ")
		button(text:"Leave"
                      return:Y
                      action:toplevel#close))
    in 
       {{QTk.build Desc} show}
       if Y then true else true end 
    end  
  end

  fun {PickPokemon}
    local G W F
       Desc=lr(label(init: "Pick the type of your pokemon")
		button(text:"Grass"
                      return:G
                      action:toplevel#close)
		button(text:"Water"
                      return:W
                      action:toplevel#close)
		button(text:"Fire"
                      return:F
                      action:toplevel#close))
    in 
       {{QTk.build Desc} show}
       if G then grass elseif W then water elseif F then fire end 
    end  
   end

   proc {ShowWindow}
      {Window show}
   end
   
   proc {CloseWindow}
      {Window close}
   end

   proc {LoadMainWindow}
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
			height:80
			handle:TextCanvas))
	      lr(canvas(bg:gray
			width:MapWidth
			height:MapHeight
			handle:Grid)
	        listbox(bg:white
		       width:50
		       height:16
		       tdscrollbar:true
		       handle:Console
                       pady: 2
                       )
	      ))
      
      Window={QTk.build Desc}
      {Window bind(event:"<Up>" action:proc{$} {Send Trainer move(up)} end)}
      {Window bind(event:"<Left>" action:proc{$} {Send Trainer move(left)} end)}
      {Window bind(event:"<Down>" action:proc{$} {Send Trainer move(down)}  end)}
      {Window bind(event:"<Right>" action:proc{$} {Send Trainer move(right)} end)}
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Gui Trainer InitialMap}
      
      fun{Inbox State Msg}
	 case State of state(starting) then
	    case Msg of start then
	       {LoadMainWindow}
	       {ShowWindow}
               {Send Trainer pokemonchoosen({PickPokemon})}
	       state(listening 0)
            [] startauto then
               {LoadMainWindow}
	       {ShowWindow}
               state(listening 0)
            else
               State
	    end
	
	 [] state(listening ConsoleIndex) then
	    case Msg of draw(Map) then
               {UpdateMap Map}
	       State
            [] redraw(NPCs PC) then
               {UpdatePlayerInfo PC}
               {UpdatePlayers PC}
               {UpdatePlayers NPCs}
               State
            [] consolemsg(Msg) then
               {AddMsgConsole Msg ConsoleIndex}
               state(listening ConsoleIndex+1)
            [] choicewild(OtherPokemoz) then
	       {Send Trainer guiwildchoice({AskChoiceWild OtherPokemoz} OtherPokemoz)}
	       State
	    [] pokemozchanged(Pokemoz Result) then
               % if lvlup Pokemon gained a boost 346 EXP. Points !
	       {UpdatePlayerPokemozInfo Pokemoz Result}
	       State
            [] fightNPC(NPC) then
               State
	    [] lost(Pokemoz) then
               {UpdatePlayerPokemozInfo Pokemoz lost}
               if {Lost} == true then
                 {CloseWindow}
	         {Send Trainer quit}
               end
	       State
	    [] win then
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
