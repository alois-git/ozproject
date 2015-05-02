functor

import
   Application
   BattleUtils
   Map
   Pokemoz

define
   local Msg in
   {BattleUtils.setupBattle 100}
   {Map.setupMap default}
   Msg = {BattleUtils.drawBattleUI {Pokemoz.newRandomPokemoz} {Pokemoz.newRandomPokemoz}}
   end
   {Application.exit 0}
end
