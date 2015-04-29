# Compile in Mozart 2.0
#     ozc -c PokemozMain.oz
#     ozengine PokemozMain.ozf
# Examples of execution
#    ozengine PokemozMain.ozf --help
#    ozengine PokemozMain.ozf -m map.txt

SOURCES=PokemozMain.oz
OBJECTS=$(SOURCES:.oz=.ozf)
#EXECUTABLE=
OZC= ozc -c

#all: $(OBJECTS)

main: PokemozMain.ozf

run: PokemozMain.ozf
	ozengine PokemozMain.ozf -m map.txt

.oz.ozf:
	$(OZC) $< -o $@

GameServer.ozf: GameServer.oz 
	$(OZC) GameServer.oz

Pokemoz.ozf: Pokemoz.oz Utils.ozf
	$(OZC) Pokemoz.oz

Trainer.ozf: Trainer.oz Utils.ozf Map.ozf
	$(OZC) Trainer.oz

Utils.ozf: Utils.oz
	$(OZC) Utils.oz

Gui.ozf: Gui.oz Utils.ozf
	$(OZC) Gui.oz

Map.ozf: Map.oz 
	$(OZC)	Map.oz

TrainerManual.ozf: TrainerManual.oz Utils.ozf
	$(OZC) TrainerManual.oz

TrainerNPC.ozf: TrainerNPC.oz Utils.ozf
	$(OZC)	TrainerNPC.oz

BattleUtils.ozf: BattleUtils.oz
	$(OZC)	BattleUtils.oz

PokemozMain.ozf: PokemozMain.oz BattleUtils.ozf Gui.ozf Utils.ozf GameServer.ozf Trainer.ozf TrainerManual.ozf TrainerNPC.ozf Pokemoz.ozf Map.ozf
	$(OZC) PokemozMain.oz

clean:
	rm -f *.ozf

.PHONY: clean run
