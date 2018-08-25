SRC := src/cesium.asm

FLAGS_ENGLISH := -i 'config_english := 1'
FLAGS_FRENCH := -i 'config_english := 0'
BIN_ENGLISH := cesium.8xp
BIN_FRENCH := cesium_french.8xp

all: english french

english:
	fasmg $(FLAGS_ENGLISH) $(SRC) $(BIN_ENGLISH)

french:
	fasmg $(FLAGS_FRENCH) $(SRC) $(BIN_FRENCH)

clean:
	rm -f $(BIN_ENGLISH) $(BIN_FRENCH)

.PHONY: all english french clean

