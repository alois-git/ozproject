functor
import
  QTk at 'x-oz://system/wp/QTk.ozf'
  OS
  Utils
export
   SetupMap
   Redraw
   GetTerrain
   GetJayPosition
   GetPositionsAround
   AddMsgConsole
   PickPokemoz
define
   Layout
   Width
   Height
   Grass
   Path
   Jay
   Center
   TrainerUp
   TrainerDown
   TrainerLeft
   TrainerRight
   MapTextures
   Window
   Grid
   Console
   TextCanvas
   WidthCell
   HeightCell
   HeightText
   ConsolePort

   proc {SetupMap MapLayout PCP}

      local CD F G W in
      CD = {OS.getCWD}

      %% Load textures
      Grass = {QTk.newImage photo(file:CD#'/images/grass.gif')}
      Path = {QTk.newImage photo(file:CD#'/images/path.gif')}
      Center = {QTk.newImage photo(file:CD#'/images/path.gif')}
      Jay = {QTk.newImage photo(file:CD#'/images/path.gif')}
      TrainerUp = {QTk.newImage photo(file:CD#'/images/trainerUp.gif')}
      TrainerDown = {QTk.newImage photo(file:CD#'/images/trainerDown.gif')}
      TrainerLeft = {QTk.newImage photo(file:CD#'/images/trainerLeft.gif')}
      TrainerRight = {QTk.newImage photo(file:CD#'/images/trainerRight.gif')}

      end
      MapTextures = maptextures(Path Grass Jay Center)

      WidthCell = 40
      HeightCell = 40
      HeightText = 10

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
      {InitWindow PCP}
      {Draw}
   end

   proc {InitWindow Trainer}
      local MapWidth MapHeight Desc in
      MapWidth = WidthCell * Width
      MapHeight = HeightCell * Height

      Desc=td(lr(canvas(bg:gray
      width:MapWidth
      height:80
      handle:TextCanvas))
           lr(canvas(bg:gray
      width:MapWidth
      height:MapHeight
      handle:Grid)
           listbox(bg:white
           width:50
           height:17
           tdscrollbar:true
           handle:Console
                       pady: 2)))

      Window={QTk.build Desc}

      {Window bind(event:"<Up>" action:proc{$} {Send Trainer guimove(up)} end)}
      {Window bind(event:"<Left>" action:proc{$} {Send Trainer guimove(left)} end)}
      {Window bind(event:"<Down>" action:proc{$} {Send Trainer guimove(down)}  end)}
      {Window bind(event:"<Right>" action:proc{$} {Send Trainer guimove(right)} end)}
      {Window show}
      end
   end

   proc {DrawImageGrid Image X Y}
      {Grid create(image WidthCell*X-(WidthCell div 2) HeightCell*Y-(HeightCell div 2) image:Image)}
   end

   proc {DrawText Text Position}
      {TextCanvas create(text WidthCell*Position.x-(WidthCell) HeightText*Position.y text:Text)}
   end

   proc {DrawTrainer Trainer}
      PlayerIcon Position Direction
   in
      {Send Trainer get(dir ret(Direction))}
      case Direction of up then
        PlayerIcon = TrainerUp
      [] down then
             PlayerIcon = TrainerDown
      [] right then
             PlayerIcon = TrainerRight
      else
            PlayerIcon = TrainerLeft
      end
      {Send Trainer get(pos ret(Position))}
      {Grid create(image WidthCell*Position.x-(WidthCell div 2) HeightCell*Position.y-(HeightCell div 2) image:PlayerIcon)}
   end

   proc {DrawNPCs NPCs}
      case NPCs of nil then
        skip
      [] H|T then
         Dir in
   {DrawTrainer H}
         {DrawNPCs T}
      end
   end

   proc {UpdatePlayerInfo Player}
      local P in
   {Send Player.port getpokemoz(P)}
   {UpdatePlayerPokemozInfo P none}
      end
   end

   proc {UpdatePlayerPokemozInfo P R}
      {TextCanvas create(rect 0 0 WidthCell*Width HeightCell*2 fill:gray outline:gray)}
      {DrawText "Pokemon:\t"#P.name p(x:4 y:2)}
      {DrawText "HP:\t"#P.hp p(x:4 y:3)}
      {DrawText "XP:\t"#P.xp p(x:4 y:4)}
      {DrawText "Level:\t"#P.lvl p(x:4 y:5)}
      {DrawText "Type:\t"#P.type p(x:4 y:6)}
   end

   proc {AddMsgConsole Msg ConsoleIndex}
      % insert(I LVS): Inserts the list of virtual strings LVS just before the element at position I.
      % 0 is adding at the start and it is very nice for log
      {Console insert(0 [Msg])}
   end

   proc {Draw}
      % draw the map textures
      for I in 1..Width do
        for J in 1..Height do
          local TextureNumber in
            TextureNumber = Layout.J.I+1
            {DrawImageGrid MapTextures.TextureNumber I J}
          end
        end
      end
   end

   proc {Redraw NPCs PC}
      {DrawTrainer PC}
      {DrawNPCs NPCs}
   end

   fun {GetTerrain X Y}
         if X < 1 orelse Y < 1 orelse X > Width orelse Y > Height then
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

   fun {PickPokemoz}
     local G W F ImgF ImgG ImgW CD
        CD = {OS.getCWD}
        ImgF = {QTk.newImage photo(file:CD#'/images/type_grass.gif')}
        ImgG = {QTk.newImage photo(file:CD#'/images/type_fire.gif')}
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

   fun {GetJayPosition}
      {GetJayPositionRec 1 1}
   end

   fun {GetJayPositionRec X Y}
     if X > Width andthen Y > Height then
        none
     elseif {GetTerrain X Y} == jay then
        pos(x:X y:Y)
     elseif X > Width then
       {GetJayPositionRec 1 Y+1}
     elseif Y > Height then
       {GetJayPositionRec X+1 1}
     else
       {GetJayPositionRec X+1 Y}
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
