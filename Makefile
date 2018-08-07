CC = g++
CFLAGS = -Wall -Wextra -Wno-unused-parameter -Werror -O2 -flto -march=native -mtune=native
LIBS = -lm -llevmar -lfaddeeva
DEBUGFLAGS = -fno-omit-frame-pointer -g3
SANITISERS = -fsanitize=undefined -fsanitize=address

all: HC CFG

HC: HC.cpp
	$(CC) $(CFLAGS) $(LIBS) -fprofile-generate HC.cpp -o HC
	./HC >/dev/null
	$(CC) $(CFLAGS) $(LIBS) -fprofile-use HC.cpp -o HC

CFG: CFG.cpp
	$(CC) $(CFLAGS) $(LIBS) -fprofile-generate CFG.cpp -o CFG
	./CFG >/dev/null
	$(CC) $(CFLAGS) $(LIBS) -fprofile-use CFG.cpp -o CFG

clean:
	rm -f *~ *.o HC CFG perf.diff

perf:
	$(CC) $(CFLAGS) $(DEBUGFLAGS) $(LIBS) CFG.cpp -o CFG
	rm perf.data
	perf record -g ./CFG >/dev/null
	#perf script | c++filt | gprof2dot -f perf | dot -Tpdf -o /tmp/cfg.pdf
	#mupdf /tmp/cfg.pdf
	#rm /tmp/cfg.pdf
	perf report -g

diff: all
	./compare_outputs

sanitise:
	$(CC) $(CFLAGS) $(DEBUGFLAGS) $(SANITISERS) $(LIBS) -fprofile-generate CFG.cpp -o CFG
	./CFG >/dev/null
	$(CC) $(CFLAGS) $(DEBUGFLAGS) $(SANITISERS) $(LIBS) -fprofile-use CFG.cpp -o CFG
