functor
import
   Application
   Property
   System
   OS
   Gui
   Utils
   GameServer
   Trainer
define
   %% Default values
   MAP = map
   WILDPOKEMOZPROBA = 30
   NBPOKEMOZ = 1
   DEFAULTSPEED = 5
   DELAY = 200
   RUNAWAYPROBA = 50
   Players
   Pokemoz
   PositionPlayer
   A

   %% Posible arguments
   Args = {Application.getArgs
           record(
              map(single char:&m type:atom default:MAP)
              pokemoz(single char:&p type:int default:NBPOKEMOZ)
              speed(single char:&s type:int default:DEFAULTSPEED)
	      wildprobability(single char:&p type:int default:WILDPOKEMOZPROBA)
              help(single char:&h default:false)
              )}

   fun {InitPlayers Game Gui}
      Players = {MakeTuple players 1}
      Pokemoz = pokemoz(hp:20 lvl:5)
      PositionPlayer = pos(x:0 y:0)
      Players.1 = player(port:{Trainer.trainer 1 Game Gui} pos:PositionPlayer)      
      Players
   end

   local
      Game
   in
   %% Show help
      if Args.help then
	 {Utils.printf "Usage: "#{Property.get 'application.url'}#" [option]"}
	 {Utils.printf "Options:"}
	 {Utils.printf "  -m, --map FILE\tFile containing the map (default "#MAP#")"}
	 {Utils.printf "  -p, --pokemoz \t Number of pokemon you can have"}
	 {Utils.printf "  -s, --speed \t Speed of the trainer [0,10]"}
	 {Utils.printf "  -p, --probability \t Probability of wild pokemon in grass"}
	 {Utils.printf "  -h, --help \t This help"}
	 {Utils.printf "Example :"}
	 {Application.exit 0}
      end
      
      {Utils.printf "Map name:\t"#Args.map}
      {Utils.printf "#Number of pokemon you can have:\t"#Args.pokemoz}
      {Utils.printf "#Speed :\t"#Args.speed}
      {Utils.printf "#Probability of wild pokemon:\t"#Args.wildprobability}
      
      local Players Map GuiObject in
	 {Utils.printf {Utils.loadMapFile {VirtualString.toAtom Args.map}}}
	 {Utils.printf "load map file"}
	 %Map = {Utils.loadMapFile {VirtualString.toAtom Args.map}}
	 Map = map( r(1 1 1 0 0 0 0) r(1 1 1 0 0 1 1) r(1 1 1 0 0 1 1) r(0 0 0 0 0 1 1) r(0 0 0 1 1 1 1) r(0 0 0 1 1 0 0) r(0 0 0 0 0 0 0))

	 {Utils.printf "Init player"}
	 Players = {InitPlayers Game GuiObject}
	 {Utils.printf "load gui"}
	 GuiObject = {Gui.gui Players.1.port Map}
	 {Utils.printf "Init game"}
	 Game = {GameServer.gameServer Map Players}

	 {Utils.printf "Start game"}
	 {Send Game start}
      end

      {Wait A}
      {Application.exit 0}
   end
end
