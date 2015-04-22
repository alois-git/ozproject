# Compile in Mozart 2.0
#     ozc -c PokemozMain.oz
#     ozengine PokemozMain.ozf
# Examples of execution
#    ozengine PokemozMain.ozf --help
#    ozengine PokemozMain.ozf -m map.txt

SOURCES=PokemozMain.oz
OBJECTS=$(SOURCES:.oz=.ozf)
#EXECUTABLE=

#all: $(OBJECTS)

run: PokemozMain.ozf
	ozengine PokemozMain.ozf -m map.txt

.oz.ozf:
	ozc -c $< -o $@

GameServer.ozf: GameServer.oz 
	ozc -c GameServer.oz

Pokemoz.ozf: Pokemoz.oz Utils.ozf
	ozc -c Pokemoz.oz

Trainer.ozf: Trainer.oz Utils.ozf
	ozc -c Trainer.oz

Utils.ozf: Utils.oz
	ozc -c Utils.oz

Gui.ozf: Gui.oz Utils.ozf
	ozc -c Gui.oz

TrainerBot.ozf: TrainerBot.oz Utils.ozf
	ozc -c TrainerBot.oz

PokemozMain.ozf: PokemozMain.oz Gui.ozf Utils.ozf GameServer.ozf Trainer.ozf TrainerBot.ozf Pokemoz.ozf
	ozc -c PokemozMain.oz

clean:
	rm -f *.ozf

.PHONY: clean run
