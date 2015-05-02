functor
import
   Application
   Property
   Utils
   GameServer
   TrainerManual
   TrainerNPC
   Map
define
   %% Default values
   MAP = map
   WILDPOKEMOZPROBA = 50
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

   local Player NPCs in
      {Utils.printf "Init player"}
      Player = {TrainerManual.newTrainerManual {Map.pickPokemoz} pos(x:7 y:7) left}
      NPCs = {TrainerNPC.newTrainerNPC  pos(x:1 y:7) left false 0}|nil

      {Utils.printf "Init game"}
      {GameServer.startGameServer default NPCs Player Args.delay Args.wildprobability}

   end

   {Application.exit 0}
end
