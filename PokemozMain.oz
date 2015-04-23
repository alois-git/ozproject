functor
import
   Application
   Property
   Gui
   Utils
   GameServer
   Trainer
   TrainerAuto
   TrainerNPC
define
   %% Default values
   MAP = map
   WILDPOKEMOZPROBA = 100
   NBPOKEMOZ = 1
   DEFAULTSPEED = 9
   DELAY = 200
   RUNAWAYPROBA = 0
   AUTOFIGHT = 2
   
   %% Posible arguments
   Args = {Application.getArgs
           record(
              map(single char:&m type:atom default:MAP)
              pokemoz(single char:&p type:int default:NBPOKEMOZ)
              speed(single char:&s type:int default:DEFAULTSPEED)
	      wildprobability(single char:&p type:int default:WILDPOKEMOZPROBA)
              runawayproba(single char:&r type:int default:RUNAWAYPROBA)
	      delay(single char:&d type:int default:DELAY)
	      autofight(single char:&a type:int default:AUTOFIGHT)
              help(single char:&h default:false)
              )}
   local
      Game
      PositionPlayer
      PositionPlayer2
      RoundLoop
   in
   %% Show help
      if Args.help then
	 {Utils.printf "Usage: "#{Property.get 'application.url'}#" [option]"}
	 {Utils.printf "Options:"}
	 {Utils.printf "  -m, --map FILE\tFile containing the map (default "#MAP#")"}
	 {Utils.printf "  -p, --pokemoz \t Number of pokemon you can have"}
	 {Utils.printf "  -s, --speed \t Speed of the trainer [0,10]"}
	 {Utils.printf "  -w, --wildprobability \t Probability of wild pokemon in grass"}
	 {Utils.printf "  -r, --runwayprobability \t Probability of run away from a wild pokemon in grass"}
	 {Utils.printf "  -a, --autofight \t 0 always run away / 1 always fight / 2 ask"}
	 {Utils.printf "  -h, --help \t This help"}
	 {Utils.printf "Example :"}
	 {Application.exit 0}
      end
      
      {Utils.printf "Map name:\t"#Args.map}
      {Utils.printf "#Number of pokemon you can have:\t"#Args.pokemoz}
      {Utils.printf "#Speed :\t"#Args.speed}
      {Utils.printf "#Probability of wild pokemon:\t"#Args.wildprobability}
      
      local Players Map GuiObject TrainerNPCObject in
	 %{Utils.printf {Utils.loadMapFile {VirtualString.toAtom Args.map}}}
	 {Utils.printf "load map file"}
	 %Map = {Utils.loadMapFile {VirtualString.toAtom Args.map}}
	 Map = map( r(1 1 1 0 0 0 0) r(1 1 1 0 0 1 1) r(1 1 1 0 0 1 1) r(0 0 0 0 0 1 1) r(0 0 0 1 1 1 1) r(0 0 0 1 1 0 0) r(0 0 0 0 0 0 0))

	 {Utils.printf "Init player"}
         Players = {MakeTuple players 2}
         PositionPlayer = pos(x:7 y:7)
         PositionPlayer2 = post(x:1 y:7)
         Players.1 = player(port:{Trainer.trainer 1 Game GuiObject Args.autofight} id:1 pos:PositionPlayer speed:Args.speed direction:left) 
         Players.2 = player(port:{Trainer.trainer 2 Game TrainerNPCObject Args.autofight} id:2 pos:PositionPlayer2 speed:Args.speed direction:right)
    
	 {Utils.printf "load gui"}
	 GuiObject = {Gui.gui Players.1.port Map}
         {Utils.printf "load bot"}
         TrainerNPCObject = {TrainerNPC.trainerNPC Players.2.port Map}

	 {Utils.printf "Init game"}
	 Game = {GameServer.gameServer Map Players Args.wildprobability Args.runawayproba}

	 {Utils.printf "Start game"}
	 {Send Game start}

   	proc {RoundLoop Delay}
            {Time.delay Delay}    
	    {Send Game round}
            {RoundLoop Delay}
   	end
	
          thread
            {RoundLoop ((10 - Args.speed) * Args.delay)}
	  end
	

      end

      {GameServer.waitEndGame}
      {Utils.printf "Leaving app"}
      {Application.exit 0}
   end
end
