functor

import
   Application
   BattleUtils
   Pokemoz

define
   {BattleUtils.setupBattle 100}
   {BattleUtils.drawBattleUI {Pokemoz.newRandomPokemoz} {Pokemoz.newRandomPokemoz}}
   {Application.exit 0}
end
