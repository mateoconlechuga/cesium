# Copyright 2015-2020 Matt "MateoConLechuga" Waltz
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

SRC := src/cesium.asm

FLAGS_ENGLISH := -i 'config_english := 1' -i 'config_french := 0'
FLAGS_FRENCH := -i 'config_english := 0' -i 'config_french := 1'
BIN_ENGLISH := cesium.8xp
BIN_FRENCH := cesium_french.8xp
RELEASE_DIR := cesium
RELEASE_ZIP := cesium.zip

all: english french

english:
	fasmg $(FLAGS_ENGLISH) $(SRC) $(BIN_ENGLISH)

french:
	fasmg $(FLAGS_FRENCH) $(SRC) $(BIN_FRENCH)

compress: english french
	convbin --oformat 8xp-auto-decompress --uppercase --name CESIUM --iformat 8x --input $(BIN_ENGLISH) --output $(BIN_ENGLISH).zx7b.8xp
	convbin --oformat 8xp-auto-decompress --uppercase --name CESIUM --iformat 8x --input $(BIN_FRENCH) --output $(BIN_FRENCH).zx7b.8xp

release: all
	convbin --oformat 8xp-auto-decompress --uppercase --name CESIUM --iformat 8x --input $(BIN_ENGLISH) --output $(BIN_ENGLISH).zx7b.8xp
	convbin --oformat 8xp-auto-decompress --uppercase --name CESIUM --iformat 8x --input $(BIN_FRENCH) --output $(BIN_FRENCH).zx7b.8xp
	rm -f $(BIN_ENGLISH) $(BIN_FRENCH) $(RELEASE_ZIP)
	rm -rf  $(RELEASE_DIR)
	mkdir -p  $(RELEASE_DIR)
	mv $(BIN_ENGLISH).zx7b.8xp $(RELEASE_DIR)/$(BIN_ENGLISH)
	mv $(BIN_FRENCH).zx7b.8xp $(RELEASE_DIR)/$(BIN_FRENCH)
	cp readme.md $(RELEASE_DIR)/readme.md
	zip -9r $(RELEASE_ZIP) $(RELEASE_DIR)

clean:
	rm -f $(BIN_ENGLISH) $(BIN_FRENCH) $(RELEASE_ZIP)
	rm -rf  $(RELEASE_DIR)

.PHONY: all english french clean release


